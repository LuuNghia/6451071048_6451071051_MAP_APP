import 
'package:draf_project/screens/shipping_address/my_shipping_address_screen.dar
t'; 
import 'package:flutter/material.dart'; 
import '../../common/styles/app_colors.dart'; 
import '../../common/styles/app_text_styles.dart'; 
import '../../common/widgets/profile_menu_item.dart'; 
import '../../routes/app_routes.dart'; 
import '../order/my_order_screen.dart'; 
import '../bank_account/my_bank_account_screen.dart'; 
import '../notifications/my_notifications.dart'; 
import 'package:get/get.dart'; 
import 'package:draf_project/controller/login_controller.dart'; 
import 'package:draf_project/controller/settings_controller.dart'; 
 
class ProfileScreen extends StatelessWidget { 
  const ProfileScreen({super.key}); 
 
  @override 
  Widget build(BuildContext context) { 
    return GetBuilder<AuthController>( 
      builder: (authController) { 
        bool loggedIn = authController.currentUser != null; 
 
        if (!loggedIn) { 
          return _buildGuestProfile(context); 
        } 
 
        return _buildUserProfile(context, authController); 
      }, 
    ); 
  } 
 
  /// ===== Header ===== 
  Widget _buildHeader(BuildContext context, AuthController authController) { 
    final user = authController.currentUser; 
 
    String fullName = ''; 
    String email = ''; 
 
    if (user != null) { 
      fullName = '${user.firstName} ${user.lastName}'; 
      email = user.email; 
    }
     return Container( 
      width: double.infinity, 
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30), 
      color: AppColors.primaryBlue, 
      child: Row( 
        children: [ 
          const CircleAvatar( 
            radius: 32, 
            backgroundImage: NetworkImage('https://i.pravatar.cc/300'), 
          ), 
          const SizedBox(width: 16), 
          Expanded( 
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [ 
                Text(fullName, style: AppTextStyle.whiteTitle), 
                const SizedBox(height: 4), 
                Text(email, style: AppTextStyle.whiteSubtitle), 
              ], 
            ), 
          ), 
          IconButton( 
            onPressed: () { 
              Navigator.pushNamed(context, AppRoutes.updateAccount); 
            }, 
            icon: const Icon(Icons.edit, color: Colors.white), 
          ), 
        ], 
      ), 
    ); 
  } 
 
  Widget _buildUserProfile( 
    BuildContext context, 
    AuthController authController, 
  ) { 
    final AuthController authController = Get.find<AuthController>(); 
 
    return Scaffold( 
      backgroundColor: AppColors.background, 
      body: Column( 
        children: [ 
          _buildHeader(context, authController), 
          Expanded( 
            child: SingleChildScrollView( 
              child: Container( 
                padding: const EdgeInsets.all(20), 
                decoration: const BoxDecoration( 
                  color: AppColors.white,
                   borderRadius: BorderRadius.only( 
                    topLeft: Radius.circular(24), 
                    topRight: Radius.circular(24), 
                  ), 
                ), 
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [ 
                    _buildAccountSetting(context), 
                    const SizedBox(height: 24), 
 
                    ///  APP SETTINGS HERE 
                    _buildAppSettingLabel(), 
                    const SizedBox(height: 16), 
                    _buildAppSettings(), 
 
                    const SizedBox(height: 24), 
                    _buildLogoutButton(context), 
                  ], 
                ), 
              ), 
            ), 
          ), 
        ], 
      ), 
    ); 
  } 
 
  /// ===== Account Setting ===== 
  Widget _buildAccountSetting(BuildContext context) { 
    return Column( 
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [ 
        Text('Cài đặt tài khoản', style: AppTextStyle.title), 
        const SizedBox(height: 16), 
 
        ProfileMenuItem( 
          icon: Icons.location_on, 
          title: 'Địa chỉ của tôi', 
          subtitle: 'Quản lý địa chỉ giao hàng', 
          onTap: () { 
            Navigator.push( 
              context, 
              MaterialPageRoute(builder: (_) => MyShippingAddressScreen()), 
            ); 
          }, 
        ), 
 
        ProfileMenuItem( 
          icon: Icons.shopping_cart,
              title: 'Giỏ hàng của tôi', 
          subtitle: 'Xem các mặt hàng trong giỏ hàng', 
          onTap: () { 
            Navigator.pushNamed(context, AppRoutes.cartOverview); 
          }, 
        ), 
 
        ProfileMenuItem( 
          icon: Icons.receipt_long, 
          title: 'Đơn hàng của tôi', 
          subtitle: 'Theo dõi đơn hàng của bạn', 
          onTap: () { 
            Navigator.push( 
              context, 
              MaterialPageRoute(builder: (_) => const MyOrderScreen()), 
            ); 
          }, 
        ), 
 
        ProfileMenuItem( 
          icon: Icons.account_balance, 
          title: 'Tài khoản ngân hàng', 
          subtitle: 'Quản lý phương thức thanh toán', 
          onTap: () { 
            Navigator.push( 
              context, 
              MaterialPageRoute(builder: (_) => MyBankAccountScreen()), 
            ); 
          }, 
        ), 
 
        ProfileMenuItem( 
          icon: Icons.notifications, 
          title: 'Thông báo', 
          subtitle: 'Cài đặt thông báo', 
          onTap: () { 
            Navigator.push( 
              context, 
              MaterialPageRoute(builder: (_) => MyNotificationScreen()), 
            ); 
          }, 
        ), 
      ], 
    ); 
  } 
 
  /// ===== LABEL ===== 
  Widget _buildAppSettingLabel() { 
    return Text('Cài đặt ứng dụng', style: AppTextStyle.title); 
  } 
 /// ===== SETTINGS ===== 
  Widget _buildAppSettings() { 
    final controller = Get.find<SettingsController>(); 
 
    return Obx( 
      () => Column( 
        children: [ 
          ProfileMenuItem( 
            icon: Icons.dark_mode, 
            title: 'Giao diện', 
            subtitle: controller.themeMode.value.name, 
            onTap: () => _showThemeDialog(controller), 
          ), 
          ProfileMenuItem( 
            icon: Icons.text_fields, 
            title: 'Cỡ chữ', 
            subtitle: controller.fontSize.value, 
            onTap: () => _showFontDialog(controller), 
          ), 
          ProfileMenuItem( 
            icon: Icons.language, 
            title: 'Ngôn ngữ', 
            subtitle: controller.locale.value.languageCode, 
            onTap: () => _showLanguageDialog(controller), 
          ), 
        ], 
      ), 
    ); 
  } 
 
  /// ===== LOGOUT ===== 
  Widget _buildLogoutButton(BuildContext context) { 
    final AuthController authController = Get.find<AuthController>(); 
 
    return Padding( 
      padding: const EdgeInsets.only(top: 16), 
      child: GestureDetector( 
        onTap: () async { 
          bool? confirm = await showDialog<bool>( 
            context: context, 
            builder: (dialogContext) { 
              return AlertDialog( 
                title: const Text('Đăng xuất'), 
                content: const Text('Bạn có chắc muốn đăng xuất không?'), 
                actions: [ 
                  TextButton( 
                    onPressed: () => Navigator.pop(dialogContext, false), 
                    child: const Text('Hủy'), 
                  ),
                  TextButton( 
                    onPressed: () => Navigator.pop(dialogContext, true), 
                    child: const Text( 
                      'Đăng xuất', 
                      style: TextStyle(color: Colors.red), 
                    ), 
                  ), 
                ], 
              ); 
            }, 
          ); 
 
          if (confirm == true) { 
            await authController.logout(); 
 
            Navigator.pushNamedAndRemoveUntil( 
              context, 
              AppRoutes.home, 
              (route) => false, 
            ); 
          } 
        }, 
        child: Container( 
          width: double.infinity, 
          padding: const EdgeInsets.symmetric(vertical: 16), 
          decoration: BoxDecoration( 
            border: Border.all(color: Colors.red), 
            borderRadius: BorderRadius.circular(12), 
          ), 
          child: const Center( 
            child: Text( 
              'Đăng xuất', 
              style: TextStyle( 
                color: Colors.red, 
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
              ), 
            ), 
          ), 
        ), 
      ), 
    ); 
  } 
} 
 
/// ===== GUEST ===== 
Widget _buildGuestProfile(BuildContext context) { 
  return Scaffold( 
    backgroundColor: AppColors.background, 
    body: Column( 
  children: [ 
        Container( 
          width: double.infinity, 
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 30), 
          color: AppColors.primaryBlue, 
          child: Column( 
            children: [ 
              const CircleAvatar( 
                radius: 40, 
                child: Icon(Icons.person, size: 40), 
              ), 
              const SizedBox(height: 16), 
              const Text( 
                'Guest User', 
                style: TextStyle( 
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white, 
                ), 
              ), 
              const SizedBox(height: 16), 
              ElevatedButton( 
                onPressed: () { 
                  Navigator.pushNamed(context, AppRoutes.login); 
                }, 
                child: const Text('Đăng nhập ngay'), 
              ), 
            ], 
          ), 
        ), 
      ], 
    ), 
  ); 
} 
 
/// ===== DIALOGS ===== 
void _showThemeDialog(SettingsController controller) { 
  Get.defaultDialog( 
    title: "Chọn Giao diện", 
    content: Column( 
      children: [ 
        ListTile( 
          title: const Text("Sáng"), 
          onTap: () { 
            controller.changeTheme('light'); 
            Get.back(); 
          }, 
        ), 
        ListTile( 
          title: const Text("Tối"),
           onTap: () { 
            controller.changeTheme('dark'); 
            Get.back(); 
          }, 
        ), 
        ListTile( 
          title: const Text("Theo hệ thống"), 
          onTap: () { 
            controller.changeTheme('system'); 
            Get.back(); 
          }, 
        ), 
      ], 
    ), 
  ); 
} 
 
void _showFontDialog(SettingsController controller) { 
  Get.defaultDialog( 
    title: "Cỡ chữ", 
    content: Column( 
      children: [ 
        ListTile( 
          title: const Text("Nhỏ"), 
          onTap: () { 
            controller.changeFontSize('small'); 
            Get.back(); 
          }, 
        ), 
        ListTile( 
          title: const Text("Vừa"), 
          onTap: () { 
            controller.changeFontSize('medium'); 
            Get.back(); 
          }, 
        ), 
        ListTile( 
          title: const Text("Lớn"), 
          onTap: () { 
            controller.changeFontSize('large'); 
            Get.back(); 
          }, 
        ), 
      ], 
    ), 
  ); 
} 
 
void _showLanguageDialog(SettingsController controller) { 
  Get.defaultDialog( 
   title: "Ngôn ngữ", 
    content: Column( 
      children: [ 
        ListTile( 
          title: const Text("Tiếng Việt"), 
          onTap: () { 
            controller.changeLanguage('vi'); 
            Get.back(); 
          }, 
        ), 
        ListTile( 
          title: const Text("English"), 
          onTap: () { 
            controller.changeLanguage('en'); 
            Get.back(); 
          }, 
        ), 
      ], 
    ), 
  ); 
} 