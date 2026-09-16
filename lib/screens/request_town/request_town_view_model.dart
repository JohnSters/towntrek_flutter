import 'package:flutter/material.dart';

import '../../core/constants/request_town_constants.dart';
import '../../models/town_request_dto.dart';
import '../../repositories/town_request_repository.dart';

class RequestTownViewModel extends ChangeNotifier {
  RequestTownViewModel({
    required TownRequestRepository repository,
    String? initialName,
    String? initialEmail,
  }) : _repository = repository {
    nameController.text = initialName?.trim() ?? '';
    emailController.text = initialEmail?.trim() ?? '';
  }

  final TownRequestRepository _repository;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? selectedProvince;
  bool isSubmitting = false;
  String? bannerMessage;
  bool bannerIsError = false;
  TownRequestSubmitResult? result;

  void setProvince(String? province) {
    selectedProvince = province;
    notifyListeners();
  }

  Future<void> submit() async {
    bannerMessage = null;
    bannerIsError = false;
    result = null;
    if (!(formKey.currentState?.validate() ?? false)) {
      notifyListeners();
      return;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      result = await _repository.submit(
        name: nameController.text.trim(),
        province: selectedProvince ?? '',
        notes: notesController.text.trim(),
        requesterEmail: emailController.text.trim(),
      );
      bannerMessage = result!.message;
      bannerIsError = false;
      if (!result!.isAlreadyListed) {
        notesController.clear();
        emailController.clear();
      }
    } on TownRequestException catch (e) {
      bannerMessage = e.message;
      bannerIsError = true;
    } catch (_) {
      bannerMessage = 'We couldn’t send your request. Please try again.';
      bannerIsError = true;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return RequestTownConstants.nameRequired;
    }
    return null;
  }

  String? validateProvince(String? value) {
    if (value == null || value.isEmpty) {
      return RequestTownConstants.provinceRequired;
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
