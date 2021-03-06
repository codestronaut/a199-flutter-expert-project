import 'package:ditonton/common/exception.dart';
import 'package:ditonton/data/datasources/movie_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockDatabaseHelper mockDatabaseHelper;
  late MovieLocalDataSourceImpl dataSource;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    dataSource = MovieLocalDataSourceImpl(databaseHelper: mockDatabaseHelper);
  });

  group('save watchlist', () {
    test(
      'should return success message when data has been inserted to database',
      () async {
        // arrange
        when(mockDatabaseHelper.insertWatchlist(testMovieTable))
            .thenAnswer((_) async => 1);

        // act
        final result = await dataSource.insertWatchlist(testMovieTable);

        // assert
        expect(result, 'Added to watchlist');
      },
    );

    test(
      'should throw DatabaseException when insert to database is failed',
      () async {
        // arrange
        when(mockDatabaseHelper.insertWatchlist(testMovieTable))
            .thenThrow(Exception());

        // act
        final call = dataSource.insertWatchlist(testMovieTable);

        // assert
        expect(() => call, throwsA(isA<DatabaseException>()));
      },
    );
  });

  group('remove watchlist', () {
    test(
      'should return success message when data has been removed from database',
      () async {
        // arrange
        when(mockDatabaseHelper.removeWatchlist(testMovieTable))
            .thenAnswer((_) async => 1);

        // act
        final result = await dataSource.removeWatchlist(testMovieTable);

        // assert
        expect(result, 'Removed from watchlist');
      },
    );

    test(
      'should throw DatabaseException when remove from database is failed',
      () async {
        // arrange
        when(mockDatabaseHelper.removeWatchlist(testMovieTable))
            .thenThrow(Exception());

        // act
        final call = dataSource.removeWatchlist(testMovieTable);

        // assert
        expect(() => call, throwsA(isA<DatabaseException>()));
      },
    );
  });

  group('get watchlist movies', () {
    test(
      'should return list of movie table from database',
      () async {
        // arrange
        when(mockDatabaseHelper.getWatchlistMovies())
            .thenAnswer((_) async => [testMovieMap]);

        // act
        final result = await dataSource.getWatchlistMovies();

        // assert
        expect(result, [testMovieTable]);
      },
    );
  });

  group('get movie detail by id', () {
    final tId = 1;

    test(
      'should return movie detail table when data is found',
      () async {
        // arrange
        when(mockDatabaseHelper.getMovieById(tId))
            .thenAnswer((_) async => testMovieMap);

        // act
        final result = await dataSource.getMovieById(tId);

        // assert
        expect(result, testMovieTable);
      },
    );

    test(
      'should return null when data is not found',
      () async {
        // arrange
        when(mockDatabaseHelper.getMovieById(tId))
            .thenAnswer((_) async => null);

        // act
        final result = await dataSource.getMovieById(tId);

        // assert
        expect(result, null);
      },
    );
  });
}
