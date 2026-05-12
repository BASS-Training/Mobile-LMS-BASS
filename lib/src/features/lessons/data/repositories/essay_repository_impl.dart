import '../../domain/repositories/essay_repository.dart';
import '../datasources/essay_local_data_source.dart';

class EssayRepositoryImpl implements EssayRepository {
  final EssayLocalDataSource localDataSource;

  EssayRepositoryImpl(this.localDataSource);

  @override
  List<String> getQuestions(String lessonId, String content) {
    return localDataSource.getQuestions(lessonId, content);
  }

  @override
  Map<int, String> getDraftAnswers(String lessonId) {
    return localDataSource.getDraftAnswers(lessonId);
  }

  @override
  Future<void> saveDraftAnswer(String lessonId, int questionIndex, String answer) async {
    await localDataSource.saveDraftAnswer(lessonId, questionIndex, answer);
  }

  // Tambahkan/Ubah bagian ini agar sesuai dengan interface
  @override
  Future<void> submitEssayAnswers(String lessonId, Map<int, String> answers) async {
    // Memanggil method saveAllDraftAnswers dari localDataSource
    await localDataSource.saveAllDraftAnswers(lessonId, answers);
  }
}