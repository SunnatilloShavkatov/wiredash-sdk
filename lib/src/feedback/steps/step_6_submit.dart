import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/feedback/_feedback.dart';
import 'package:wiredash/wiredash.dart';

class Step6Submit extends StatefulWidget {
  const Step6Submit({Key? key}) : super(key: key);

  @override
  State<Step6Submit> createState() => _Step6SubmitState();
}

class _Step6SubmitState extends State<Step6Submit> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    final localizations = WiredashLocalizations.of(context)!;
    return StepPageScaffold(
      indicator: const FeedbackProgressIndicator(
        flowStatus: FeedbackFlowStatus.submit,
      ),
      title: const Text('Submit your feedback'),
      shortTitle: const Text('Submit'),
      description: const Text(
        'Please review your data before submission. '
        'You can navigate back to adjust your feedback',
      ),
      discardLabel: Text(localizations.discardFeedback),
      discardConfirmLabel: Text(localizations.reallyDiscard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TronButton(
                color: context.theme.secondaryColor,
                leadingIcon: Wirecons.arrow_left,
                label: localizations.back,
                onTap: context.feedbackModel.goToPreviousStep,
              ),
              TronButton(
                label: 'Submit',
                leadingIcon: Wirecons.check,
                onTap: () {
                  context.feedbackModel.submitFeedback();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TronLabeledButton(
                child: Text(showDetails ? 'Hide Details' : 'Show Details'),
                onTap: () {
                  setState(() {
                    showDetails = !showDetails;
                  });
                },
              ),
            ],
          ),
          if (showDetails) feedbackDetails(),
        ],
      ),
    );
  }

  Widget feedbackDetails() {
    final model = context.feedbackModel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTileTheme(
        textColor: context.theme.secondaryTextColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Feedback Details',
              style: context.theme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            FutureBuilder<PersistedFeedbackItem>(
              future: model.createFeedback(),
              builder: (context, snapshot) {
                final data = snapshot.data;
                if (data == null) {
                  return const SizedBox();
                }
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Message'),
                      subtitle: Text(data.message),
                    ),
                    if (model.selectedLabels.isNotEmpty)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Labels'),
                        subtitle: Text(
                          model.selectedLabels.map((it) => it.title).join(', '),
                        ),
                      ),
                    if (model.hasAttachments)
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Screenshots'),
                        // TODO add exact number
                        subtitle: Text('1 Screenshot'),
                      ),
                    if (data.email != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Contact email'),
                        subtitle: Text(data.email ?? ''),
                      ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Locale'),
                      subtitle: Text(
                        data.appInfo.appLocale,
                      ),
                    ),
                    if (data.deviceInfo.userAgent != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('User agent'),
                        subtitle: Text('${data.deviceInfo.userAgent}'),
                      ),
                    if (!kIsWeb)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Platform'),
                        subtitle: Text(
                          '${data.deviceInfo.platformOS} '
                          '${data.deviceInfo.platformOSVersion} '
                          '(${data.deviceInfo.platformLocale})',
                        ),
                      ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Build Info'),
                      subtitle: Text(
                        [
                          data.buildInfo.compilationMode,
                          data.buildInfo.buildNumber,
                          data.buildInfo.buildVersion,
                          data.buildInfo.buildCommit
                        ].where((it) => it != null).join(', '),
                      ),
                    ),
                    if (!kIsWeb)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dart version'),
                        subtitle: Text(
                          '${data.deviceInfo.platformVersion}',
                        ),
                      ),
                    if (data.customMetaData != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Custom metaData'),
                        subtitle: Text(
                          data.customMetaData!.entries
                              .map((it) => '${it.key}=${it.value}, ')
                              .join(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
