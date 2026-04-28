import 'package:flutter/material.dart'; 
import '../../common/widgets/primary_button.dart'; 
import '../../data/services/login_auth_service.dart';
import '../../routes/app_routes.dart'; 
import '../../utils/validators.dart'; 
 
class ForgetPasswordScreen extends StatelessWidget { 
  ForgetPasswordScreen({super.key}); 
 
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); 
  final TextEditingController emailController = TextEditingController(); 
  final AuthService _authService = AuthService();
 
  Future<void> _submit(BuildContext context) async {
    final bool isValid = formKey.currentState!.validate(); 
 
    if (!isValid) { 
      return; 
    } 
 
    try {
      final String email = emailController.text.trim();
      await _authService.sendPasswordResetEmail(email);

      if (!context.mounted) {
        return;
      }

      Navigator.pushNamed(
        context,
        AppRoutes.resetEmailSent,
        arguments: email,
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar(title: const Text('Khôi phục mật khẩu')), 
      body: Padding( 
        padding: const EdgeInsets.all(24), 
        child: Form( 
          key: formKey, 
          child: Column( 
            children: [ 
              TextFormField( 
 controller: emailController, 
                keyboardType: TextInputType.emailAddress, 
                decoration: const InputDecoration( 
                  labelText: 'Email', 
                  border: OutlineInputBorder(), 
                ), 
                validator: (value) { 
                  return Validators.validateEmail(value ?? ''); 
                }, 
              ), 
 
              const SizedBox(height: 24), 
 
              PrimaryButton( 
                title: 'Gửi yêu cầu', 
                onPressed: () => _submit(context), 
              ), 
            ], 
          ), 
        ), 
      ), 
    ); 
  } 
} 