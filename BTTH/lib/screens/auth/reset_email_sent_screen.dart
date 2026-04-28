import 'package:flutter/material.dart'; 
import '../../common/widgets/primary_button.dart'; 
import '../../data/services/login_auth_service.dart';
import '../../routes/app_routes.dart'; 
 
class ResetEmailSentScreen extends StatelessWidget { 
  final String email; 
  static final AuthService _authService = AuthService();
 
  const ResetEmailSentScreen({super.key, required this.email}); 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      body: SafeArea( 
        child: Padding( 
          padding: const EdgeInsets.all(24), 
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [ 
              const Icon(Icons.email_outlined, size: 100), 
 
              const SizedBox(height: 24), 
 
              const Text( 
                'Yêu cầu đã được gửi', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 
              ), 
 
              const SizedBox(height: 12), 
 
              Text('Liên kết khôi phục mật khẩu đã gửi tới:'), 
 
              const SizedBox(height: 8), 
 
              Text(email, style: const TextStyle(fontWeight: 
FontWeight.bold)), 
 
              const SizedBox(height: 32), 
  PrimaryButton( 
                title: 'Xong', 
                onPressed: () { 
                  Navigator.pushNamedAndRemoveUntil( 
                    context, 
                    AppRoutes.login, 
                    (route) => false, 
                  ); 
                }, 
              ), 
 
              TextButton(
                onPressed: () async {
                  try {
                    await _authService.sendPasswordResetEmail(email);
                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email đã được gửi lại')),
                    );
                  } catch (e) {
                    if (!context.mounted) {
                      return;
                    }

                    final message =
                        e.toString().replaceFirst('Exception: ', '');
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(message)));
                  }
                },
                child: const Text('Gửi lại email'),
              ),
            ], 
          ), 
        ), 
      ), 
    ); 
  } 
} 