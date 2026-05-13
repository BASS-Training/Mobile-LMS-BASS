import 'package:lms_mobile_app/src/features/home/data/datasources/home_remote_data_source.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  // Tambahkan Http Client / Dio di sini jika sudah ada backend
  
  @override
  Future<void> submitJoinClassToken(String token) async {
    // TODO: Ganti dengan pemanggilan API POST sebenarnya (contoh: dio.post('/join-class'))
    // Simulasi delay jaringan
    await Future.delayed(const Duration(milliseconds: 900));
    
    // Simulasi sukses
    return;
  }
}