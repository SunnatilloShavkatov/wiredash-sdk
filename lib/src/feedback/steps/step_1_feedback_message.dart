import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/feedback/_feedback.dart';

class Step1FeedbackMessage extends StatefulWidget {
  const Step1FeedbackMessage({Key? key}) : super(key: key);

  @override
  State<Step1FeedbackMessage> createState() => _Step1FeedbackMessageState();
}

class _Step1FeedbackMessageState extends State<Step1FeedbackMessage>
    with TickerProviderStateMixin {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: FeedbackModelProvider.of(context, listen: false).feedbackMessage,
    )..addListener(() {
        final text = _controller.text;
        if (context.feedbackModel.feedbackMessage != text) {
          context.feedbackModel.feedbackMessage = text;
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
    final localizations = WiredashLocalizations.of(context)!;
    return StepPageScaffold(
      indicator: const FeedbackProgressIndicator(
        flowStatus: FeedbackFlowStatus.message,
      ),
      title: Text(localizations.sendUsYourFeedback),
      shortTitle: Text(localizations.composeMessage),
      description: Text(
        localizations.addShortDescriptionOfWhatYouEncountered,
      ),
      discardLabel: Text(localizations.discardFeedback),
      discardConfirmLabel: Text(localizations.reallyDiscard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // reduce size when it doesn't fit
          Flexible(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.multiline,
              minLines: context.theme.windowSize.height > 400 ? 3 : 2,
              maxLines: 10,
              maxLength: 2048,
              buildCounter: _getCounterText,
              style: context.theme.bodyTextStyle,
              cursorColor: context.theme.primaryColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: context.theme.primaryBackgroundColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.theme.secondaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.theme.secondaryColor),
                ),
                errorBorder: InputBorder.none,
                hoverColor: context.theme.brightness == Brightness.light
                    ? context.theme.primaryBackgroundColor.darken(0.015)
                    : context.theme.primaryBackgroundColor.lighten(0.015),
                hintText:
                    localizations.theresAnUnknownErrorWhenITryToChangeMyAvatar,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                hintStyle: context.theme.body2TextStyle,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TronButton(
                color: context.theme.secondaryColor,
                label: localizations.close,
                onTap: context.wiredashModel.hide,
              ),
              TronButton(
                label: localizations.next,
                trailingIcon: Wirecons.arrow_right,
                onTap: context.feedbackModel.feedbackMessage == null
                    ? null
                    : context.feedbackModel.goToNextStep,
              ),
            ],
          )
        ],
      ),
    );
  }
}

Widget? _getCounterText(
  /// The build context for the TextField.
  BuildContext context, {

  /// The length of the string currently in the input.
  required int currentLength,

  /// The maximum string length that can be entered into the TextField.
  required int? maxLength,

  /// Whether or not the TextField is currently focused.  Mainly provided for
  /// the [liveRegion] parameter in the [Semantics] widget for accessibility.
  required bool isFocused,
}) {
  final max = maxLength ?? 2048;
  final remaining = max - currentLength;

  Color _getCounterColor() {
    if (remaining >= 150) {
      return Colors.green.shade400.withOpacity(0.8);
    } else if (remaining >= 50) {
      return Colors.orange.withOpacity(0.8);
    }
    return Theme.of(context).errorColor;
  }

  return Text(
    remaining > 150 ? '' : remaining.toString(),
    style: WiredashTheme.of(context)!
        .inputErrorTextStyle
        .copyWith(color: _getCounterColor()),
  );
}
