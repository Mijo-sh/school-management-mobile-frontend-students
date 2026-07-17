// import '../../../../../../core/localization/app_localization.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
//
// class DrawerChangePicDialogWidget extends StatefulWidget {
//   final String imagePath;
//
//   const DrawerChangePicDialogWidget({super.key, required this.imagePath});
//
//   @override
//   State<DrawerChangePicDialogWidget> createState() => _DrawerChangePicDialogWidgetState();
// }
//
// class _DrawerChangePicDialogWidgetState extends State<DrawerChangePicDialogWidget> {
//   final ImagePicker _picker = ImagePicker();
//   String? profilePicPath;
//
//   bool _cameraPermissionGranted = false;
//   bool _storagePermissionGranted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     if(widget.imagePath.isNotEmpty) {
//       profilePicPath = widget.imagePath;
//
//     } else {
//       profilePicPath = null;
//     }
//   // }
//   //
//   // Future<bool> _checkPermission(Permission permission, bool alreadyGranted) async {
//   //   if(alreadyGranted) return true;
//   //
//   //   final status = await permission.status;
//   //
//   //   if (status.isGranted) return true;
//   //   if (status.isDenied) {
//   //     final result = await permission.request();
//   //     return result.isGranted;
//   //
//   //   }
//     if(status.isPermanentlyDenied) {
//       await openAppSettings();
//
//     }
//     return false;
//   }
//
//   Future<void> _pickImage({
//     required ImageSource source,
//     required void Function(String path) onPicked
//   }) async {
//     final permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
//     final alreadyGranted = source == ImageSource.camera ? _cameraPermissionGranted : _storagePermissionGranted;
//     final granted = await _checkPermission(permission, alreadyGranted);
//
//     if(!granted) return;
//     if (source == ImageSource.camera) _cameraPermissionGranted = true;
//     if (source == ImageSource.gallery) _storagePermissionGranted = true;
//
//     final XFile? image = await _picker.pickImage(source: source);
//
//     if(image != null) {
//       onPicked(image.path);
//     }
//   }
//
//   Future<void> pickProfilePic() async {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20))
//       ),
//       builder: (_) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: Text("change_pic_gallery".tr(context)),
//               onTap: () {
//                 context.pop();
//                 _pickImage(
//                   source: ImageSource.gallery,
//                   onPicked: (path) {
//                     // context.read<ProfileBloc>().add(PersonalImageChanged(path));
//                   }
//                 );
//               }
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: Text("change_pic_camera".tr(context)),
//               onTap: () {
//                 context.pop();
//                 _pickImage(
//                   source: ImageSource.camera,
//                   onPicked: (path) {
//                     // context.read<ProfileBloc>().add(PersonalImageChanged(path));
//                   }
//                 );
//               }
//             )
//           ]
//         )
//       )
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context).colorScheme;
//
//     return AlertDialog(
//       icon: CircleAvatar(
//         radius: 30,
//         backgroundColor: theme.primary.withOpacity(0.1),
//         child: Icon(
//           Icons.photo_camera_back_rounded,
//           color: theme.primary,
//           size: 30
//         )
//       ),
//       title: Text("drawer_change_picture".tr(context)),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             "change_pic_content".tr(context),
//             textAlign: TextAlign.center
//           ),
//           const SizedBox(height: 10),
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               CircleAvatar(
//                 radius: 60,
//                 backgroundImage: profilePicPath != null ? AssetImage(profilePicPath!)
//                   : AssetImage(widget.imagePath) as ImageProvider
//               ),
//               Positioned(
//                 bottom: -5,
//                 right: -5,
//                 child: CircleAvatar(
//                   radius: 18,
//                   backgroundColor: theme.primary,
//                   child: IconButton(
//                     padding: EdgeInsets.zero,
//                     iconSize: 18,
//                     onPressed: pickProfilePic,
//                     icon: Icon(
//                       Icons.edit,
//                       color: theme.onPrimary
//                     )
//                   )
//                 )
//               )
//             ]
//           )
//         ]
//       ),
//       actionsAlignment: MainAxisAlignment.center,
//       actions: [
//         ElevatedButton(
//           onPressed: () => context.pop(),
//           child: Text("button_cancel".tr(context))
//         ),
//         FilledButton(
//           onPressed: () {
//             // احفظ الصورة الجديدة هنا
//             context.pop();
//           },
//           child: Text("change_pic_confirm".tr(context))
//         )
//       ]
//     );
//   }
// }