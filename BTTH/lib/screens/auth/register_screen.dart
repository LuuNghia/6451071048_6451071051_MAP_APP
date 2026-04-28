import 'package:btl/controller/register_controller.dart'; 
import 'package:flutter/material.dart'; 
import '../../common/widgets/primary_button.dart'; 
import '../../common/widgets/social_login_button.dart'; 
import '../../utils/validators.dart'; 
import '../../routes/app_routes.dart'; 
 
class RegisterScreen extends StatefulWidget { 
  const RegisterScreen({super.key}); 
 @override 
  State<RegisterScreen> createState() => _RegisterScreenState(); 
} 
 
class _RegisterScreenState extends State<RegisterScreen> { 
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); 
 
  final TextEditingController firstNameController = TextEditingController(); 
  final TextEditingController lastNameController = TextEditingController(); 
  final TextEditingController usernameController = TextEditingController(); 
  final TextEditingController emailController = TextEditingController(); 
  final TextEditingController phoneController = TextEditingController(); 
  final TextEditingController passwordController = TextEditingController(); 
  final RegisterController registerController = RegisterController(); 
  bool isPasswordHidden = true; 
  bool agreePolicy = false; 
 
  Future<void> _submitRegister() async { 
    final bool isValid = formKey.currentState!.validate(); 
 
    if (!isValid) { 
      return; 
    } 
 
    if (!agreePolicy) { 
      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar(
          content: Text('Bạn phải đồng ý Chính sách bảo mật và Điều khoản sử dụng'),
        ), 
      ); 
      return; 
    } 
 
    String? error = await registerController.register( 
      firstName: firstNameController.text.trim(), 
      lastName: lastNameController.text.trim(), 
      username: usernameController.text.trim(), 
      email: emailController.text.trim(), 
      phone: phoneController.text.trim(), 
      password: passwordController.text.trim(), 
    ); 
 
    if (error != null) { 
      ScaffoldMessenger.of( 
        context, 
      ).showSnackBar(SnackBar(content: Text(error))); 
      return; 
    } 
 
    Navigator.pushNamed( 
      context, 
 AppRoutes.verifyEmail, 
      arguments: emailController.text.trim(), 
    ); 
  } 
 
  InputDecoration _inputDecoration( 
    String label, 
    IconData icon, { 
    Widget? suffixIcon, 
  }) { 
    return InputDecoration( 
      labelText: label, 
      border: const OutlineInputBorder(), 
      prefixIcon: Icon(icon), 
      suffixIcon: suffixIcon, 
    ); 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar(title: const Text('Tạo tài khoản')), 
      body: SafeArea( 
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(24), 
          child: Form( 
            key: formKey, 
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [ 
                const Text( 
                  "Nhập thông tin tài khoản đăng ký ở đây", 
                  style: TextStyle(fontSize: 26, fontWeight: 
FontWeight.bold), 
                ), 
 
                const SizedBox(height: 32), 
 
                TextFormField( 
                  controller: firstNameController, 
                  decoration: _inputDecoration('Họ', Icons.person), 
                  validator: (value) { 
                    return Validators.validateRequired( 
                      value ?? '', 
                      'Họ', 
                    ); 
                  }, 
                ), 
 
                const SizedBox(height: 16), 


   TextFormField( 
                  controller: lastNameController, 
                  decoration: _inputDecoration( 
                    'Tên', 
                    Icons.person_outline, 
                  ), 
                  validator: (value) { 
                    return Validators.validateRequired( 
                      value ?? '', 
                      'Tên', 
                    ); 
                  }, 
                ), 
 
                const SizedBox(height: 16), 
 
                TextFormField( 
                  controller: usernameController, 
                  decoration: _inputDecoration( 
                    'Tên người dùng', 
                    Icons.alternate_email, 
                  ), 
                  validator: (value) { 
                    return Validators.validateRequired(
                      value ?? '',
                      'Tên người dùng',
                    ); 
                  }, 
                ), 
 
                const SizedBox(height: 16), 
 
                TextFormField( 
                  controller: emailController, 
                  keyboardType: TextInputType.emailAddress, 
                  decoration: _inputDecoration('Email', Icons.email), 
                  validator: (value) { 
                    return Validators.validateEmail(value ?? ''); 
                  }, 
                ), 
 
                const SizedBox(height: 16), 
 
                TextFormField( 
                  controller: phoneController, 
                  keyboardType: TextInputType.phone, 
                  decoration: _inputDecoration('Số điện thoại', Icons.phone), 
                  validator: (value) { 
                    return Validators.validatePhone(value ?? ''); 
                  }, 
                ), 
 const SizedBox(height: 16), 
 
                TextFormField( 
                  controller: passwordController, 
                  obscureText: isPasswordHidden, 
                  decoration: _inputDecoration( 
                    'Mật khẩu', 
                    Icons.lock, 
                    suffixIcon: IconButton( 
                      icon: Icon( 
                        isPasswordHidden 
                            ? Icons.visibility_off 
                            : Icons.visibility, 
                      ), 
                      onPressed: () { 
                        setState(() { 
                          isPasswordHidden = !isPasswordHidden; 
                        }); 
                      }, 
                    ), 
                  ), 
                  validator: (value) { 
                    return Validators.validatePassword(value ?? ''); 
                  }, 
                ), 
 
                const SizedBox(height: 16), 
 
                Row( 
                  children: [ 
                    Checkbox( 
                      value: agreePolicy, 
                      onChanged: (value) { 
                        setState(() { 
                          agreePolicy = value ?? false; 
                        }); 
                      }, 
                    ), 
                    Expanded( 
                      child: Wrap( 
                        children: const [ 
                          Text('Tôi đồng ý với '), 
                          Text( 
                            'Chính sách bảo mật', 
                            style: TextStyle( 
                              color: Colors.blue, 
                              decoration: TextDecoration.underline, 
                            ), 
                          ),
                            Text(' và '), 
                          Text( 
                            'Điều khoản sử dụng', 
                            style: TextStyle( 
                              color: Colors.blue, 
                              decoration: TextDecoration.underline, 
                            ), 
                          ), 
                        ], 
                      ), 
                    ), 
                  ], 
                ), 
 
                const SizedBox(height: 16), 
 
                PrimaryButton( 
                  title: 'Tạo tài khoản', 
                  onPressed: _submitRegister, 
                ), 
 
                const SizedBox(height: 24), 
 
                const Center(child: Text('Hoặc')), 
 
                const SizedBox(height: 16), 
 
                SocialLoginButton( 
                  icon: Icons.g_mobiledata, 
                  title: 'Đăng ký với Google', 
                  onPressed: () {}, 
                ), 
 
                const SizedBox(height: 12), 
 
                SocialLoginButton( 
                  icon: Icons.facebook, 
                  title: 'Đăng ký với Facebook', 
                  onPressed: () {}, 
                ), 
              ], 
            ), 
          ), 
        ), 
      ), 
    ); 
  } 
} 