import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/feedback/_feedback.dart';
import 'package:wiredash/src/utils/email_validator.dart';

class Step5Email extends StatefulWidget {
  const Step5Email({Key? key}) : super(key: key);

  @override
  State<Step5Email> createState() => _Step5EmailState();
}

class _Step5EmailState extends State<Step5Email> with TickerProviderStateMixin {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: FeedbackModelProvider.of(context, listen: false).userEmail,
    )..addListener(() {
        final text = _controller.text;
        if (context.feedbackModel.userEmail != text) {
          context.feedbackModel.userEmail = text;
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      indicator:
          const FeedbackProgressIndicator(flowStatus: FeedbackFlowStatus.email),
      title: const Text('Get email updates for your issue'),
      shortTitle: const Text('Contact'),
      description: const Text('Add your email address below or leave empty'),
      discardLabel: const Text('Discard Feedback'),
      discardConfirmLabel: const Text('Really? Discard!'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: TextFormField(
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              cursorColor: context.theme.primaryColor,
              style: context.theme.bodyTextStyle,
              onFieldSubmitted: (_) {
                if (context.feedbackModel.validateForm()) {
                  context.feedbackModel.goToNextStep();
                }
              },
              validator: (data) {
                final email = data ?? '';
                if (email.isEmpty) {
                  // leaving this field empty is ok
                  return null;
                }
                final valid = const EmailValidator().validate(email);
                return valid
                    ? null
                    : WiredashLocalizations.of(context)!.validationHintEmail;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: context.theme.primaryBackgroundColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.theme.secondaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.theme.secondaryColor),
                ),
                hintText: 'mail@example.com',
                hoverColor: context.theme.brightness == Brightness.light
                    ? context.theme.primaryBackgroundColor.darken(0.015)
                    : context.theme.primaryBackgroundColor.lighten(0.015),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                hintStyle: context.theme.body2TextStyle,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TronButton(
                color: context.theme.secondaryColor,
                leadingIcon: Wirecons.arrow_left,
                label: 'Back',
                onTap: context.feedbackModel.goToPreviousStep,
              ),
              TronButton(
                label: 'Next',
                trailingIcon: Wirecons.arrow_right,
                onTap: () {
                  try {
                    context.feedbackModel.goToNextStep();
                  } on FormValidationException {
                    // validator triggered, TextFormField shows error
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
