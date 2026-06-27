import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/injector/injector_container.dart';
import '../widgets/splash/splash_background_widget.dart';
import '../widgets/splash/splash_content_widget.dart';
import '../widgets/splash/splash_version_widget.dart';
import '../../domain/services/app_entry_decider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/splash/splash_bloc.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  String appVersion = '';
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _textOffset;
  late Animation<double> _textOpacity;
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      // 👇 نحمّل صورة خلفية اللوجين مسبقاً وهنّي بالـ Splash
      precacheImage(
        const AssetImage('assets/images/background_login.jpg'),
        context,
      );
    }
  }
  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500)
    );

    _logoScale = Tween<double>(
      begin: 0.2,
      end: 1
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack
      )
    );

    _logoOpacity = Tween<double>(
      begin: 5,
      end: 1
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn
      )
    );

    _textOffset = Tween<Offset>(
      begin: const Offset(0, 0.9),
      end: Offset.zero
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut
      )
    );

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.4,
          1,
          curve: Curves.easeIn
        )
      )
    );

    _controller.forward();//.then((_) {
    //   if(!mounted) return;
    //   context.read<SplashBloc>().add(GetAppSessionSplashEvent());
    // });
    
    Future.delayed(
      const Duration(milliseconds: 3000),
      () {
        if(!mounted) return;
        context.read<SplashBloc>().add(GetAppSessionSplashEvent());
      }
    );
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {appVersion = 'v ${packageInfo.version}';});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if(state is NavigateSplashState) {
          di<AppEntryDecider>().decideHandler(context, state.decision);

        }
        if(state is ErrorSplashState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));

        }
      },
      child: Scaffold(
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SplashBackgroundWidget(),
              SplashContentWidget(
                logoScale: _logoScale,
                logoOpacity: _logoOpacity,
                textOffset: _textOffset,
                textOpacity: _textOpacity
              ),
              SplashVersionWidget(appVersion: appVersion)
            ]
          )
        )
      )
    );
  }
}