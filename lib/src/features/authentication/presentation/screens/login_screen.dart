// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
// import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
// import 'package:lms_mobile_app/src/core/utils/validators.dart';
// import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
// import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
// import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
// import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _handleLogin(BuildContext context) {
//     if (_formKey.currentState?.validate() ?? false) {
//       context.read<AuthBloc>().add(
//         AuthLoginEvent(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//         ),
//       );
//     }
//   }

//   void _togglePasswordVisibility() {
//     setState(() {
//       _obscurePassword = !_obscurePassword;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthSuccess) {
//             context.go(AppRoutes.main);
//           } else if (state is AuthFailure) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: AppColors.red,
//                 duration: const Duration(seconds: 3),
//               ),
//             );
//           }
//         },
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [AppColors.red, AppColors.tomato, Color(0xFFF7F0F0)],
//             ),
//           ),
//           child: SafeArea(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 final sheetTop = constraints.maxHeight * 0.4;

//                 return Stack(
//                   children: [
//                     Positioned(
//                       top: -60,
//                       left: -36,
//                       child: _Ornament(
//                         size: 160,
//                         color: AppColors.red.withValues(alpha: 0.10),
//                       ),
//                     ),
//                     Positioned(
//                       top: 40,
//                       right: -26,
//                       child: _Ornament(
//                         size: 110,
//                         color: const Color(0xFFF4C7C7).withValues(alpha: 0.16),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: -42,
//                       right: -28,
//                       child: _Ornament(
//                         size: 140,
//                         color: AppColors.tomato.withValues(alpha: 0.08),
//                       ),
//                     ),
//                     Positioned(
//                       left: 18,
//                       right: 18,
//                       top: 14,
//                       child: _HeroHeader(
//                         onRegisterTap: () => context.go(AppRoutes.register),
//                       ),
//                     ),
//                     Positioned.fill(
//                       top: sheetTop,
//                       child: _LoginSheet(
//                         formKey: _formKey,
//                         emailController: _emailController,
//                         passwordController: _passwordController,
//                         obscurePassword: _obscurePassword,
//                         onTogglePasswordVisibility: _togglePasswordVisibility,
//                         onLogin: () => _handleLogin(context),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _HeroHeader extends StatelessWidget {
//   final VoidCallback onRegisterTap;

//   const _HeroHeader({required this.onRegisterTap});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 240,
//       child: Stack(
//         children: [
//           const Positioned(
//             left: 0,
//             top: 12,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Hello!',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 34,
//                     fontWeight: FontWeight.w900,
//                     letterSpacing: -0.8,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Welcome to Bass Training LMS',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 13,
//                     height: 1.35,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             right: 0,
//             top: 0,
//             child: Container(
//               width: 82,
//               height: 82,
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.12),
//                 borderRadius: BorderRadius.circular(24),
//               ),
//             ),
//           ),
//           Positioned(
//             right: 22,
//             top: 32,
//             child: SizedBox(
//               width: 178,
//               height: 156,
//               child: CustomPaint(painter: _LmsIllustrationPainter()),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _LoginSheet extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController emailController;
//   final TextEditingController passwordController;
//   final bool obscurePassword;
//   final VoidCallback onTogglePasswordVisibility;
//   final VoidCallback onLogin;

//   const _LoginSheet({
//     required this.formKey,
//     required this.emailController,
//     required this.passwordController,
//     required this.obscurePassword,
//     required this.onTogglePasswordVisibility,
//     required this.onLogin,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(34),
//           topRight: Radius.circular(34),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 28,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Form(
//         key: formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'Login',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.w900,
//                 color: AppColors.charcoal,
//               ),
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               'Gunakan akun yang sama untuk web dan mobile.',
//               style: TextStyle(
//                 fontSize: 13.5,
//                 height: 1.45,
//                 color: AppColors.stone,
//               ),
//             ),
//             const SizedBox(height: 22),
//             _InputShell(
//               child: TextFormField(
//                 controller: emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                   hintText: AppStrings.email,
//                   prefixIcon: Icon(Icons.mail_outline),
//                 ),
//                 validator: Validators.validateEmail,
//                 onChanged: (_) {
//                   context.read<AuthBloc>().add(const AuthClearErrorEvent());
//                 },
//               ),
//             ),
//             const SizedBox(height: 14),
//             _InputShell(
//               child: TextFormField(
//                 controller: passwordController,
//                 obscureText: obscurePassword,
//                 decoration: InputDecoration(
//                   hintText: AppStrings.password,
//                   prefixIcon: const Icon(Icons.lock_outline),
//                   suffixIcon: IconButton(
//                     onPressed: onTogglePasswordVisibility,
//                     icon: Icon(
//                       obscurePassword
//                           ? Icons.visibility_outlined
//                           : Icons.visibility_off_outlined,
//                     ),
//                   ),
//                 ),
//                 validator: Validators.validatePassword,
//                 onChanged: (_) {
//                   context.read<AuthBloc>().add(const AuthClearErrorEvent());
//                 },
//               ),
//             ),
//             const SizedBox(height: 10),
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () => context.go(AppRoutes.register),
//                 child: const Text(
//                   'Belum punya akun? Daftar',
//                   style: TextStyle(
//                     color: AppColors.red,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 6),
//             BlocBuilder<AuthBloc, AuthState>(
//               builder: (context, authState) {
//                 final isLoading = authState is AuthLoading;
//                 return ElevatedButton(
//                   onPressed: isLoading ? null : onLogin,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.red,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: isLoading
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.white,
//                             ),
//                           ),
//                         )
//                       : const Text(
//                           AppStrings.login,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                 );
//               },
//             ),
//             const SizedBox(height: 12),
//             Center(
//               child: Text(
//                 'Satu akun untuk semua akses pembelajaran.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: AppColors.stone.withValues(alpha: 0.82),
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _InputShell extends StatelessWidget {
//   final Widget child;

//   const _InputShell({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F5FF),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: const Color(0xFFE4DCF9)),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//       child: child,
//     );
//   }
// }

// class _Ornament extends StatelessWidget {
//   final double size;
//   final Color color;

//   const _Ornament({required this.size, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(shape: BoxShape.circle, color: color),
//     );
//   }
// }

// class _LmsIllustrationPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;

//     paint.color = Colors.white.withValues(alpha: 0.95);
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromCenter(
//           center: Offset(size.width * 0.52, size.height * 0.62),
//           width: size.width * 0.46,
//           height: size.height * 0.34,
//         ),
//         const Radius.circular(18),
//       ),
//       paint,
//     );

//     paint.color = const Color(0xFFE9E2E2);
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromCenter(
//           center: Offset(size.width * 0.52, size.height * 0.80),
//           width: size.width * 0.58,
//           height: size.height * 0.07,
//         ),
//         const Radius.circular(12),
//       ),
//       paint,
//     );

//     paint.color = const Color(0xFF1F1B33);
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(
//           size.width * 0.38,
//           size.height * 0.29,
//           size.width * 0.28,
//           size.height * 0.19,
//         ),
//         const Radius.circular(12),
//       ),
//       paint,
//     );

//     final screenRect = RRect.fromRectAndRadius(
//       Rect.fromLTWH(
//         size.width * 0.39,
//         size.height * 0.31,
//         size.width * 0.26,
//         size.height * 0.15,
//       ),
//       const Radius.circular(10),
//     );
//     paint.shader = const LinearGradient(
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//       colors: [Color(0xFF1D2B53), Color(0xFFB3121E)],
//     ).createShader(screenRect.outerRect);
//     canvas.drawRRect(screenRect, paint);
//     paint.shader = null;

//     paint.color = Colors.white.withValues(alpha: 0.8);
//     canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.38), 11, paint);
//     canvas.drawCircle(
//       Offset(size.width * 0.47, size.height * 0.38),
//       3.4,
//       paint,
//     );
//     canvas.drawCircle(
//       Offset(size.width * 0.57, size.height * 0.38),
//       3.4,
//       paint,
//     );

//     paint.color = const Color(0xFFF8D66D);
//     canvas.drawCircle(
//       Offset(size.width * 0.58, size.height * 0.40),
//       3.5,
//       paint,
//     );

//     paint.color = const Color(0xFFFFC7D0);
//     canvas.drawCircle(Offset(size.width * 0.73, size.height * 0.24), 17, paint);

//     paint.color = const Color(0xFFF4F1FF);
//     canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.18), 14, paint);

//     paint.color = const Color(0xFFA7F3D0).withValues(alpha: 0.82);
//     final leafLeft = Path()
//       ..moveTo(size.width * 0.29, size.height * 0.63)
//       ..quadraticBezierTo(
//         size.width * 0.15,
//         size.height * 0.45,
//         size.width * 0.23,
//         size.height * 0.23,
//       )
//       ..quadraticBezierTo(
//         size.width * 0.30,
//         size.height * 0.38,
//         size.width * 0.29,
//         size.height * 0.63,
//       )
//       ..close();
//     canvas.drawPath(leafLeft, paint);

//     paint.color = const Color(0xFFB8F2E6).withValues(alpha: 0.70);
//     final leafRight = Path()
//       ..moveTo(size.width * 0.76, size.height * 0.61)
//       ..quadraticBezierTo(
//         size.width * 0.83,
//         size.height * 0.37,
//         size.width * 0.73,
//         size.height * 0.20,
//       )
//       ..quadraticBezierTo(
//         size.width * 0.69,
//         size.height * 0.38,
//         size.width * 0.76,
//         size.height * 0.61,
//       )
//       ..close();
//     canvas.drawPath(leafRight, paint);

//     paint.color = const Color(0xFFF9D0D3);
//     canvas.drawCircle(Offset(size.width * 0.24, size.height * 0.50), 8, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
import 'package:lms_mobile_app/src/core/utils/validators.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthLoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go(AppRoutes.main);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFEBEC), Color(0xFFFDF7F7), Color(0xFFF7F0F0)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  left: -36,
                  child: _Ornament(
                    size: 160,
                    color: AppColors.red.withValues(alpha: 0.10),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: -26,
                  child: _Ornament(
                    size: 110,
                    color: const Color(0xFFF4C7C7).withValues(alpha: 0.16),
                  ),
                ),
                Positioned(
                  bottom: -42,
                  right: -28,
                  child: _Ornament(
                    size: 140,
                    color: AppColors.tomato.withValues(alpha: 0.08),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final panelWidth = constraints.maxWidth
                        .clamp(0, 420)
                        .toDouble();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: Column(
                            children: [
                              SizedBox(
                                width: panelWidth,
                                child: _IllustrationPanel(
                                  onRegisterTap: () =>
                                      context.go(AppRoutes.register),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _LoginCard(
                                formKey: _formKey,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                onTogglePasswordVisibility:
                                    _togglePasswordVisibility,
                                onLogin: () => _handleLogin(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IllustrationPanel extends StatelessWidget {
  final VoidCallback onRegisterTap;

  const _IllustrationPanel({required this.onRegisterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.red, const Color(0xFF8E1B22)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 8,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 168,
                  child: CustomPaint(
                    painter: _LmsIllustrationPainter(),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hello!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome to Bass Training LMS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onLogin;

  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Align(
            //   alignment: Alignment.center, // Ubah ke Alignment.center jika ingin di tengah
            //   child: Image.asset(
            //     'assets/images/bass_logo.png', // Sesuaikan dengan path file logomu
            //     height: 100, // Sesuaikan tingginya
            //     fit: BoxFit.contain,
            //   ),
            // ),
            // const SizedBox(height: 16),
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Gunakan akun yang sama untuk web dan mobile.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.stone,
              ),
            ),
            const SizedBox(height: 20),
            _InputShell(
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: AppStrings.email,
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: Validators.validateEmail,
                onChanged: (_) {
                  context.read<AuthBloc>().add(const AuthClearErrorEvent());
                },
              ),
            ),
            const SizedBox(height: 14),
            _InputShell(
              child: TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: AppStrings.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: onTogglePasswordVisibility,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: Validators.validatePassword,
                onChanged: (_) {
                  context.read<AuthBloc>().add(const AuthClearErrorEvent());
                },
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.register),
                child: const Text(
                  'Belum punya akun? Daftar',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final isLoading = authState is AuthLoading;
                return ElevatedButton(
                  onPressed: isLoading ? null : onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          AppStrings.login,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InputShell extends StatelessWidget {
  final Widget child;

  const _InputShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4DCF9)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: child,
    );
  }
}

class _Ornament extends StatelessWidget {
  final double size;
  final Color color;

  const _Ornament({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _LmsIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = Colors.white.withValues(alpha: 0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.52, size.height * 0.62),
          width: size.width * 0.46,
          height: size.height * 0.34,
        ),
        const Radius.circular(18),
      ),
      paint,
    );

    paint.color = const Color(0xFFE9E2E2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.52, size.height * 0.80),
          width: size.width * 0.58,
          height: size.height * 0.07,
        ),
        const Radius.circular(12),
      ),
      paint,
    );

    paint.color = const Color(0xFF1F1B33);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.38,
          size.height * 0.29,
          size.width * 0.28,
          size.height * 0.19,
        ),
        const Radius.circular(12),
      ),
      paint,
    );

    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.39,
        size.height * 0.31,
        size.width * 0.26,
        size.height * 0.15,
      ),
      const Radius.circular(10),
    );
    paint.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1D2B53), Color(0xFFB3121E)],
    ).createShader(screenRect.outerRect);
    canvas.drawRRect(screenRect, paint);
    paint.shader = null;

    paint.color = Colors.white.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.38), 11, paint);
    canvas.drawCircle(
      Offset(size.width * 0.47, size.height * 0.38),
      3.4,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.57, size.height * 0.38),
      3.4,
      paint,
    );

    paint.color = const Color(0xFFF8D66D);
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.40),
      3.5,
      paint,
    );

    paint.color = const Color(0xFFFFC7D0);
    canvas.drawCircle(Offset(size.width * 0.73, size.height * 0.24), 17, paint);

    paint.color = const Color(0xFFF4F1FF);
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.18), 14, paint);

    paint.color = const Color(0xFFA7F3D0).withValues(alpha: 0.82);
    final leafLeft = Path()
      ..moveTo(size.width * 0.29, size.height * 0.63)
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.45,
        size.width * 0.23,
        size.height * 0.23,
      )
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.38,
        size.width * 0.29,
        size.height * 0.63,
      )
      ..close();
    canvas.drawPath(leafLeft, paint);

    paint.color = const Color(0xFFB8F2E6).withValues(alpha: 0.70);
    final leafRight = Path()
      ..moveTo(size.width * 0.76, size.height * 0.61)
      ..quadraticBezierTo(
        size.width * 0.83,
        size.height * 0.37,
        size.width * 0.73,
        size.height * 0.20,
      )
      ..quadraticBezierTo(
        size.width * 0.69,
        size.height * 0.38,
        size.width * 0.76,
        size.height * 0.61,
      )
      ..close();
    canvas.drawPath(leafRight, paint);

    paint.color = const Color(0xFFF9D0D3);
    canvas.drawCircle(Offset(size.width * 0.24, size.height * 0.50), 8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
