import '../widgets/onboarding/onboarding_background_widget.dart';
import '../widgets/onboarding/onboarding_header_widget.dart';
import '../../../../core/assets_manager/images_manager.dart';
import '../../../../core/localization/app_localization.dart';
import '../widgets/onboarding/onboarding_image_widget.dart';
import '../widgets/onboarding/onboarding_card_widget.dart';
import '../../../../core/routing/route_name.dart';
import '../bloc/onboarding/onboarding_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller = PageController();
  int _index = 0;

  late final pages = [
    (
      image: ImagesManager.onboarding1,
      title: "onboarding1_title".tr(context),
      description: "onboarding1_description".tr(context)
    ),
    (
      image: ImagesManager.onboarding2,
      title: "onboarding2_title".tr(context),
      description: "onboarding2_description".tr(context)
    ),
    (
      image: ImagesManager.onboarding3,
      title: "onboarding3_title".tr(context),
      description: "onboarding3_description".tr(context)
    )
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if(_index < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeInOut
      );
    } else {
      context.read<OnboardingBloc>().add(CompleteOnboardingEvent());
    }
  }

  void _previous() {
    if(_index > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeInOut
      );
    }
  }

  void _completeOnboarding() async {
    context.read<OnboardingBloc>().add(CompleteOnboardingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if(state is SuccessOnboardingState) {
          // context.go(RouteName.logIn);
          context.go(RouteName.homeShell);
        }
        if(state is ErrorOnboardingState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message))
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              OnboardingBackgroundWidget(),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: pages.length,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder: (_, i) {
                          final item = pages[i];
                          final double progress = (i + 1) / pages.length;
                          return Column(
                            children: [
                              const SizedBox(height: 120),
                              OnboardingImageWidget(image: item.image),
                              const SizedBox(height: 40),
                              OnboardingCardWidget(
                                title: item.title,
                                description: item.description,
                                onNext: _next,
                                progress: progress
                              ),
                              const Spacer()
                            ]
                          );
                        }
                      ),
                    )
                  ]
                )
              ),
              OnboardingHeaderWidget(
                onBack: _previous,
                onSkip: _completeOnboarding
              )
            ]
          )
        )
      )
    );
  }
}