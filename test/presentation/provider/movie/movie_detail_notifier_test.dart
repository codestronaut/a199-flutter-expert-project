import 'package:dartz/dartz.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_recommendations.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/usecases/get_watchlist_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist.dart';
import 'package:ditonton/domain/usecases/save_watchlist.dart';
import 'package:ditonton/presentation/provider/movie_detail_notifier.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../dummy_data/dummy_objects.dart';
import 'movie_detail_notifier_test.mocks.dart';

@GenerateMocks([
  GetMovieDetail,
  GetMovieRecommendations,
  GetWatchListStatus,
  SaveWatchlist,
  RemoveWatchlist,
])
void main() {
  late int listenerCallCount;
  late MockGetMovieDetail mockGetMovieDetail;
  late MockGetMovieRecommendations mockGetMovieRecommendations;
  late MockGetWatchListStatus mockGetWatchlistStatus;
  late MockSaveWatchlist mockSaveWatchlist;
  late MockRemoveWatchlist mockRemoveWatchlist;
  late MovieDetailNotifier provider;

  setUp(() {
    listenerCallCount = 0;
    mockGetMovieDetail = MockGetMovieDetail();
    mockGetMovieRecommendations = MockGetMovieRecommendations();
    mockGetWatchlistStatus = MockGetWatchListStatus();
    mockSaveWatchlist = MockSaveWatchlist();
    mockRemoveWatchlist = MockRemoveWatchlist();
    provider = MovieDetailNotifier(
      getMovieDetail: mockGetMovieDetail,
      getMovieRecommendations: mockGetMovieRecommendations,
      getWatchListStatus: mockGetWatchlistStatus,
      saveWatchlist: mockSaveWatchlist,
      removeWatchlist: mockRemoveWatchlist,
    )..addListener(() {
        listenerCallCount++;
      });
  });

  final tId = 1;

  final tMovie = Movie(
    adult: false,
    backdropPath: '/path.jpg',
    genreIds: [1, 2, 3, 4],
    id: 1,
    originalTitle: 'Original Title',
    overview: 'Overview',
    popularity: 1.0,
    posterPath: '/path.jpg',
    releaseDate: '2022-01-01',
    title: 'Title',
    video: false,
    voteAverage: 1.0,
    voteCount: 1,
  );

  final tMovies = <Movie>[tMovie];

  void _arrangeUsecase() {
    when(mockGetMovieDetail.execute(tId))
        .thenAnswer((_) async => Right(testMovieDetail));
    when(mockGetMovieRecommendations.execute(tId))
        .thenAnswer((_) async => Right(tMovies));
  }

  group('movie detail', () {
    test(
      'should get movie detail data from the usecase',
      () async {
        // arrange
        _arrangeUsecase();

        // act
        await provider.fetchMovieDetail(tId);

        // assert
        verify(mockGetMovieDetail.execute(tId));
        verify(mockGetMovieRecommendations.execute(tId));
      },
    );

    test(
      'should change state to loading when usecase is called',
      () {
        // arrange
        _arrangeUsecase();

        // act
        provider.fetchMovieDetail(tId);

        // assert
        expect(provider.movieState, equals(RequestState.Loading));
        expect(listenerCallCount, equals(1));
      },
    );

    test(
      'should change movie when data is gotten successfully',
      () async {
        // arrange
        _arrangeUsecase();

        // act
        await provider.fetchMovieDetail(tId);

        // assert
        expect(provider.movieState, equals(RequestState.Loaded));
        expect(provider.movie, equals(testMovieDetail));
        expect(listenerCallCount, equals(3));
      },
    );

    test(
      'should change recommendation movies when data is gotten successfully',
      () async {
        // arrange
        _arrangeUsecase();

        // act
        await provider.fetchMovieDetail(tId);

        // assert
        expect(provider.movieState, equals(RequestState.Loaded));
        expect(provider.movieRecommendations, equals(tMovies));
      },
    );

    test('should return server expeception when error', () async {
      // arrange
      when(mockGetMovieDetail.execute(tId))
          .thenAnswer((_) async => Left(ServerFailure('Server failure')));
      when(mockGetMovieRecommendations.execute(tId))
          .thenAnswer((_) async => Right(tMovies));

      // act
      await provider.fetchMovieDetail(tId);

      // assert
      expect(provider.movieState, equals(RequestState.Error));
      expect(provider.message, equals('Server failure'));
      expect(listenerCallCount, equals(2));
    });
  });

  group('get movie recommendations', () {
    test(
      'should get movie recommendations data from the usecase',
      () async {
        // arrange
        _arrangeUsecase();

        // act
        await provider.fetchMovieDetail(tId);

        // assert
        verify(mockGetMovieRecommendations.execute(tId));
        expect(provider.movieRecommendations, equals(tMovies));
      },
    );

    test(
      'should change recommendation state when data is gotten successfully',
      () async {
        // arrange
        _arrangeUsecase();

        // act
        await provider.fetchMovieDetail(tId);

        // assert
        expect(provider.recommendationState, equals(RequestState.Loaded));
        expect(provider.movieRecommendations, equals(tMovies));
      },
    );

    test(
      'should change error message when request in unsuccessful',
      () async {
        // arrange
        when(mockGetMovieDetail.execute(tId))
            .thenAnswer((_) async => Right(testMovieDetail));
        when(mockGetMovieRecommendations.execute(tId))
            .thenAnswer((_) async => Left(ServerFailure('Failed')));

        // act
        await provider.fetchMovieDetail(tId);

        // assert
        expect(provider.recommendationState, equals(RequestState.Error));
        expect(provider.message, equals('Failed'));
      },
    );
  });

  group('movie watchlist', () {
    test(
      'should get the watchlist status',
      () async {
        // arrange
        when(mockGetWatchlistStatus.execute(1)).thenAnswer((_) async => true);

        // act
        await provider.loadWatchlistStatus(1);

        // assert
        expect(provider.isAddedToWatchlist, equals(true));
      },
    );

    test(
      'should execute save watchlist when function called',
      () async {
        // arrange
        when(mockSaveWatchlist.execute(testMovieDetail))
            .thenAnswer((_) async => Right('Success'));
        when(mockGetWatchlistStatus.execute(testMovieDetail.id))
            .thenAnswer((_) async => true);

        // act
        await provider.addWatchlist(testMovieDetail);

        // assert
        verify(mockSaveWatchlist.execute(testMovieDetail));
      },
    );

    test(
      'should execute remove watchlist when function called',
      () async {
        // arrange
        when(mockRemoveWatchlist.execute(testMovieDetail))
            .thenAnswer((_) async => Right('Removed'));
        when(mockGetWatchlistStatus.execute(testMovieDetail.id))
            .thenAnswer((_) async => false);

        // act
        await provider.removeFromWatchlist(testMovieDetail);

        // assert
        verify(mockRemoveWatchlist.execute(testMovieDetail));
      },
    );

    test(
      'should change watchlist status when adding watchlist success',
      () async {
        // arrange
        when(mockSaveWatchlist.execute(testMovieDetail))
            .thenAnswer((_) async => Right('Added to watchlist'));
        when(mockGetWatchlistStatus.execute(testMovieDetail.id))
            .thenAnswer((_) async => true);

        // act
        await provider.addWatchlist(testMovieDetail);

        // assert
        verify(mockGetWatchlistStatus.execute(testMovieDetail.id));
        expect(provider.isAddedToWatchlist, equals(true));
        expect(provider.watchlistMessage, equals('Added to watchlist'));
        expect(listenerCallCount, equals(1));
      },
    );

    test(
      'should change watchlist message when adding watchlist failed',
      () async {
        // arrange
        when(mockSaveWatchlist.execute(testMovieDetail))
            .thenAnswer((_) async => Left(DatabaseFailure('Failed')));
        when(mockGetWatchlistStatus.execute(testMovieDetail.id))
            .thenAnswer((_) async => false);

        // act
        await provider.addWatchlist(testMovieDetail);

        // assert
        expect(provider.watchlistMessage, equals('Failed'));
        expect(listenerCallCount, equals(1));
      },
    );
  });
}
