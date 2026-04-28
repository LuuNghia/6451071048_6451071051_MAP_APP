import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/styles/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:btl/controller/update_account_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateAccountScreen extends StatelessWidget {
  const UpdateAccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Khởi tạo controller thông qua Get.put để quản lý vòng đời tốt hơn
    final UpdateAccountController _controller = Get.put(
      UpdateAccountController(),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền xám nhạt để nổi bật các Card
      appBar: AppBar(
        title: const Text(
          'Hồ sơ của tôi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: _controller.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text("Không thể tải dữ liệu người dùng"),
            );
          }

          final authUserEmail = FirebaseAuth.instance.currentUser?.email;
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final firestoreEmail = data['email'];

          if (authUserEmail != firestoreEmail) {
            _controller.syncEmailAfterVerification();
          }

          // Xử lý dữ liệu hiển thị
          final fullName =
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';
          final username = data['username'] ?? 'Not set';
          final email = data['email'] ?? '';
          final phone = data['phone'] ?? 'Not set';
          final id = data['id'] ?? '';
          final gender = data['gender'] ?? 'Not set';

          final dynamic dobData = data['dateOfBirth'];
          String dateOfBirth = 'Chưa cập nhật';
          if (dobData != null) {
            if (dobData is Timestamp) {
              dateOfBirth = DateFormat('dd/MM/yyyy').format(dobData.toDate());
            } else if (dobData is String) {
              dateOfBirth = dobData;
            }
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header Avatar
                _buildAvatarHeader(context),

                const SizedBox(height: 10),

                // Group 1: Profile Info
                _buildSectionCard(
                  title: 'Thông tin hồ sơ',
                  items: [
                    _buildTile(
                      context,
                      Icons.person_outline,
                      'Họ và tên', // Đã đổi từ 'Name'
                      fullName,
                      () => Navigator.pushNamed(context, AppRoutes.changeName),
                    ),
                    _buildTile(
                      context,
                      Icons.alternate_email,
                      'Tên đăng nhập', // Đã đổi từ 'Username'
                      username,
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.changeUsername,
                      ),
                    ),
                    _buildTile(
                      context,
                      Icons.lock_outline,
                      'Mật khẩu',
                      '********',
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.changePassword,
                      ),
                    ),
                  ],
                ),

                // Group 2: Personal Info
                _buildSectionCard(
                  title: 'Thông tin cá nhân',
                  items: [
                    _buildTile(
                      context,
                      Icons.fingerprint,
                      'Mã người dùng',
                      id,
                      () {
                        // Đã đổi từ 'User ID'
                        Clipboard.setData(ClipboardData(text: id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Mã đã được sao chép vào khay nhớ tạm",
                            ), // Đã thuần Việt hóa
                          ),
                        );
                      },
                      trailing: Icons.copy,
                    ),
                    _buildTile(
                      context,
                      Icons.mail_outline,
                      'Email',
                      email,
                      () => Navigator.pushNamed(context, AppRoutes.changeEmail),
                    ),
                    _buildTile(
                      context,
                      Icons.phone_android,
                      'Số điện thoại',
                      phone,
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.changePhoneNumber,
                      ),
                    ),
                    _buildTile(
                      context,
                      Icons.cake_outlined,
                      'Ngày sinh',
                      dateOfBirth,
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.changeDateofBirth,
                      ),
                    ),
                    _buildTile( 
                      context, 
                      Icons.wc_outlined, 
                      'Giới tính', 
                      getVietnameseGender(gender), 
                      () => Navigator.pushNamed(context, AppRoutes.changeGender), 
                    ),
                  ],
                ),

                // Danger Zone
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'Đóng tài khoản',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget Avatar với Header background
  Widget _buildAvatarHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://vn.images.search.yahoo.com/images/view;_ylt=AwrPoZuCt_BpKi07zBhtUwx.;_ylu=c2VjA3NyBHNsawNpbWcEb2lkA2U0YmM3NGI4NWM4MTAyYTk4N2MyYzYxODM1MjU1MmU2BGdwb3MDMgRpdANiaW5n?back=https%3A%2F%2Fvn.images.search.yahoo.com%2Fsearch%2Fimages%3Fp%3Davt%2B%25C4%2591%25E1%25BA%25B9p%26type%3DE210VN1589G0%26fr%3Dmcafee%26fr2%3Dpiv-web%26tab%3Dorganic%26ri%3D2&w=1082&h=1082&imgurl=antimatter.vn%2Fwp-content%2Fuploads%2F2022%2F11%2Fhinh-anh-avatar-cute.jpg&rurl=https%3A%2F%2Ff5fashion.vn%2Ftop-hon-52-ve-avatar-dep-nhat-hinh-nen-facebook-cute-hay-nhat%2F&size=367KB&p=avt+%C4%91%E1%BA%B9p&oid=e4bc74b85c8102a987c2c618352552e6&fr2=piv-web&fr=mcafee&tt=Top+h%C6%A1n+52+v%E1%BB%81+avatar+%C4%91%E1%BA%B9p+nh%E1%BA%A5t+h%C3%ACnh+n%E1%BB%81n+facebook+cute+hay+nh%E1%BA%A5t+-+f5+fashion&b=0&ni=21&no=2&ts=&tab=organic&sigr=btKpCqWdwvDt&sigb=C7GqimJStts_&sigi=WcbzIILaRm7A&sigt=QaeSlmwZwDZ8&.crumb=QS9/zjKtRR2&fr=mcafee&fr2=piv-web&type=E210VN1589G0',
                  ),
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.blue,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Thay đổi ảnh đại diện",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Widget Card bao bọc một section
  Widget _buildSectionCard({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }

  // Widget từng dòng thông tin
  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    VoidCallback onTap, {
    IconData trailing = Icons.arrow_forward_ios,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(trailing, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
