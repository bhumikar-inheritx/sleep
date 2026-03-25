import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../datasources/remote/firestore_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final FirestoreDatasource remoteDataSource;
  final HiveDatasource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity?> getUserProfile(String uid) async {
    try {
      // Try remote first
      final remoteData = await remoteDataSource.getData('users', uid);
      if (remoteData != null) {
        final profile = UserEntity.fromMap(remoteData);
        // Cache locally
        await localDataSource.put(HiveDatasource.profileBox, uid, remoteData);
        return profile;
      }
    } catch (e) {
      // Fallback to local
      final localData = localDataSource.get(HiveDatasource.profileBox, uid);
      if (localData != null) {
        return UserEntity.fromMap(Map<String, dynamic>.from(localData));
      }
    }
    return null;
  }

  @override
  Future<void> saveUserProfile(UserEntity profile) async {
    final data = profile.toMap();
    if (profile.uid != null) {
      // Save local
      await localDataSource.put(HiveDatasource.profileBox, profile.uid!, data);
      // Save remote
      await remoteDataSource.setData('users', profile.uid!, data);
    }
  }
}
