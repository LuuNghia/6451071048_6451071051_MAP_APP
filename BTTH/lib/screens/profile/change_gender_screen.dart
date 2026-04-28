
import 'package:flutter/material.dart'; 
import 'package:btl/controller/update_account_controller.dart'; 
 
enum Gender { male, female, other } 
 
class ChangeGenderScreen extends StatefulWidget { 
  const ChangeGenderScreen({super.key}); 
 
  @override 
  State<ChangeGenderScreen> createState() => _ChangeGenderScreenState(); 
}
class _ChangeGenderScreenState extends State<ChangeGenderScreen> { 
  Gender _selectedGender = Gender.male; 
  final UpdateAccountController _controller = UpdateAccountController(); 
  bool _isLoading = false; 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar(title: const Text('Đổi giới tính')), 
      body: Padding( 
        padding: const EdgeInsets.all(20), 
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [ 
            const Text( 
              'Chọn giới tính', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
            ), 
 
            const SizedBox(height: 20), 
 
            _buildRadioTile(title: 'Nam', value: Gender.male), 
 
            _buildRadioTile(title: 'Nữ', value: Gender.female), 
 
            _buildRadioTile(title: 'Khác', value: Gender.other), 
 
            const Spacer(), 
 
            SizedBox( 
              width: double.infinity, 
              height: 48, 
              child: ElevatedButton( 
                onPressed: _isLoading 
                    ? null 
                    : () async { 
                        setState(() { 
                          _isLoading = true; 
                        }); 
 
                        await _controller.updateGender( 
                          _selectedGender.name, // male / female / other 
                        ); 
 
                        setState(() { 
                          _isLoading = false; 
                        }); 
 
                        Navigator.pop(context); 
      }, 
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Lưu'), 
              ), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
 
  Widget _buildRadioTile({required String title, required Gender value}) { 
    return RadioListTile<Gender>( 
      title: Text(title), 
      value: value, 
      groupValue: _selectedGender, 
      onChanged: (Gender? newValue) { 
        if (newValue != null) { 
          setState(() { 
            _selectedGender = newValue; 
          }); 
        } 
      }, 
    ); 
  } 
} 