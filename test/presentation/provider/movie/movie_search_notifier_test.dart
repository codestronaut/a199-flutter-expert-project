import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/search_movies.dart';
import 'package:ditonton/presentation/provider/movie_search_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'movie_search_notifier_test.mocks.dart';

@GenerateMocks([SearchMovies])
void main() {
  late int listenerCallCount;
  late MockSearchMovies mockSearchMovies;
  late MovieSearchNotifier provider;

  setUp(() {
    listenerCallCount = 0;
    mockSearchMovies = MockSearchMovies();
    provider = MovieSearchNotifier(searchMovies: mockSearchMovies)
      ..addListener(() {
        listenerCallCount++;
      });
  });

  final tMovieModel = Movie(
    adult: false,
    backdropPath: '/1Rr5SrvHxMXHu5RjKpaMba8VTzi.jpg',
    genreIds: [28, 12, 878],
    id: 634649,
    originalTitle: 'Spider-Man: No Way Home',
    overview:
        'Peter Parker is unmasked and no longer able to separate his normal life from the high-stakes of being a super-hero. When he asks for help from Doctor Strange the stakes become even more dangerous, forcing him to discover what it truly means to be Spider-Man.',
    popularity: 8817.063,
    posterPath: '/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg',
    releaseDate: '2021-12-15',
    title: 'Spider-Man: No Way Home',
    video: false,
    voteAverage: 8.4,
    voteCount: 3427,
  );

  final tMovieList = <Movie>[tMovieModel];

  final tQuery = 'spiderman';

  group('search a movie', () {
    test(
      'should change state to loading when usecase is called',
      () async {
        // arrange
        when(mockSearchMovies.execute(tQuery))
            .thenAnswer((_) async => Right(tMovieList));

        // act
        provider.fetchMovieSearch(tQuery);

        // assert
        expect(provider.state, equals(RequestState.Loading));
      },
    );

    test(
      'should change search result when data is gotten successfully',
      () async {
        // arrange
        when(mockSearchMovies.execute(tQuery))
            .thenAnswer((_) async => Right(tMovieList));

        // act
        await provider.fetchMovieSearch(tQuery);

        // assert
        expect(provider.state, equals(RequestState.Loaded));
        expect(provider.searchResult, equals(tMovieList));
        expect(listenerCallCount, equals(2));
      },
    );

    test(
      'should return server failure when error',
      () async {
        // arrange
        when(mockSearchMovies.execute(tQuery))
            .thenAnswer((_) async => Left(ServerFailure('Server failure')));

        // act
        await provider.fetchMovieSearch(tQuery);

        // assert
        expect(provider.state, equals(RequestState.Error));
        expect(provider.message, equals('Server failure'));
        expect(listenerCallCount, equals(2));
      },
    );
  });
}
