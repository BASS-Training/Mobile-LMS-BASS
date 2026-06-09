/// Centralised copy for the registration flow.
///
/// Keeping every label, hint, error message, and option list here keeps the
/// step widgets free of magic strings and gives us a single place to wire up
/// i18n later.
class RegisterStrings {
  const RegisterStrings._();

  // Header.
  static const badge = 'BUAT AKUN BARU';
  static const title = 'Daftar Akun ✨';
  static const subtitle = 'Satu akun untuk web dan mobile dengan data yang sama.';

  // Step labels (progress indicator).
  static const stepAccountLabel = 'Program & Akun';
  static const stepPersonalLabel = 'Data Diri';
  static const stepOccupationLabel = 'Pekerjaan';

  // Step 1 — Program & account.
  static const stepAccountTitle = 'Program & Akun';
  static const stepAccountSubtitle =
      'Pilih jalur kelas lalu lengkapi identitas akun.';
  static const programSectionLabel = 'Pilih Jalur Kelas';
  static const programRegularTitle = 'Kelas Reguler BASS';
  static const programRegularSubtitle = 'Langsung daftar di web atau mobile.';
  static const programAvpnTitle = 'Literasi AI (AVPN)';
  static const programAvpnSubtitle = 'Akun masuk status pending validasi.';
  static const avpnInfo =
      'Jika memilih AVPN AI, akun akan dibuat dengan status menunggu validasi admin.';

  static const nameLabel = 'Nama Lengkap';
  static const nameHint = 'Masukkan nama lengkap';
  static const emailLabel = 'Email';
  static const emailHint = 'Email';
  static const passwordLabel = 'Password';
  static const passwordHint = 'Password';
  static const confirmPasswordLabel = 'Konfirmasi Password';
  static const confirmPasswordHint = 'Ulangi password';

  // Step 2 — Personal data.
  static const stepPersonalTitle = 'Data Diri';
  static const stepPersonalSubtitle =
      'Isi data diri yang dipakai untuk validasi akun.';
  static const genderSectionLabel = 'Jenis Kelamin';
  static const genderMaleTitle = 'Laki-laki';
  static const genderMaleSubtitle = 'Data sesuai identitas';
  static const genderFemaleTitle = 'Perempuan';
  static const genderFemaleSubtitle = 'Data sesuai identitas';
  static const dateOfBirthLabel = 'Tanggal Lahir';
  static const dateOfBirthHint = 'Pilih tanggal lahir';
  static const institutionLabel = 'Nama Instansi/Sekolah';
  static const institutionHint = 'Nama sekolah, kampus, atau perusahaan';

  // Date picker.
  static const datePickerHelp = 'Pilih tanggal lahir';
  static const datePickerCancel = 'Batal';
  static const datePickerConfirm = 'Pilih';

  // Step 3 — Occupation.
  static const stepOccupationTitle = 'Pekerjaan';
  static const stepOccupationSubtitle = 'Pilih kategori pekerjaan Anda.';
  static const occupationSectionLabel = 'Pekerjaan';

  // Navigation.
  static const back = 'Kembali';
  static const next = 'Selanjutnya';
  static const submit = 'Daftar Sekarang';
  static const submitting = 'Mendaftar...';
  static const alreadyHaveAccount = 'Sudah punya akun? ';
  static const signIn = 'Masuk';

  // Feedback.
  static const incompleteForm = 'Lengkapi semua data dulu sebelum mendaftar.';
  static const registerSuccess = 'Akun berhasil dibuat. Masuk ke aplikasi...';

  // Validation messages.
  static const nameRequired = 'Nama wajib diisi';
  static const emailRequired = 'Email wajib diisi';
  static const emailInvalid = 'Format email tidak valid';
  static const passwordRequired = 'Password wajib diisi';
  static const passwordTooShort = 'Password minimal 6 karakter';
  static const confirmPasswordRequired = 'Konfirmasi password wajib diisi';
  static const confirmPasswordMismatch = 'Konfirmasi password tidak sama';
  static const classInterestRequired = 'Pilih jalur kelas terlebih dahulu';
  static const genderRequired = 'Pilih jenis kelamin terlebih dahulu';
  static const dateOfBirthRequired = 'Tanggal lahir wajib diisi';
  static const institutionRequired = 'Nama instansi wajib diisi';
  static const occupationRequired = 'Pilih pekerjaan terlebih dahulu';

  // Domain option values.
  static const classRegular = 'regular';
  static const classAvpn = 'avpn_ai';
  static const genderMale = 'male';
  static const genderFemale = 'female';

  static const List<String> occupationOptions = [
    'Pelajar/Mahasiswa',
    'PNS/ASN',
    'TNI/Polri',
    'Karyawan Swasta',
    'Pegawai BUMN',
    'Wiraswasta',
    'Buruh/Tenaga Harian Lepas',
    'Pedagang',
    'Sopir/Pengemudi',
    'Ibu Rumah Tangga',
    'Pensiunan',
    'Tidak Bekerja',
    'Lainnya',
  ];
}
