import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:urbanest_app/controllers/rent_request_provider.dart';
import 'package:urbanest_app/model/listing.dart';

class RentRequestFormPage extends StatefulWidget {
  final Listing listing;

  const RentRequestFormPage({Key? key, required this.listing})
      : super(key: key);

  @override
  _RentRequestFormPageState createState() => _RentRequestFormPageState();
}

class _RentRequestFormPageState extends State<RentRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  File? _salarySlip;

  // Form fields
  late String _fullName;
  late DateTime _dob;
  late String _email;
  late String _phone;
  late String _address;
  late String _jobTitle;
  late String _employmentStatus;
  late double _monthlyIncome;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _dob = DateTime.now().subtract(const Duration(days: 365 * 20)); // Default to 20 years ago
  }

  Future<void> _pickSalarySlip() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _salarySlip = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_salarySlip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your salary slip'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    _formKey.currentState!.save();

    try {
      final provider = Provider.of<RentRequestController>(
        context,
        listen: false,
      );
      await provider.createRentRequest(
        listingId: widget.listing.id!,
        fullName: _fullName,
        dob: _dob,
        email: _email,
        phone: _phone,
        address: _address,
        jobTitle: _jobTitle,
        employmentStatus: _employmentStatus,
        monthlyIncome: _monthlyIncome,
        salarySlip: _salarySlip!,
      );

      // Show success dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Request Submitted'),
          content: const Text(
            'Your rent request has been successfully submitted!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return success
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting request: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.brightness == Brightness.dark
                ? const ColorScheme.dark(
                    primary: Color(0xFF4F8AFE),
                    surface: Color(0xFF22242A),
                    background: Color(0xFF191B20),
                  )
                : ColorScheme.light(
                    primary: theme.colorScheme.primary,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Color getInputFillColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF22242A) : Colors.grey[50]!;
  }

  Color getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF191B20) : Colors.white;
  }

  Color getLabelColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black;
  }

  Color getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey[400]! : Colors.grey[600]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Request Form'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Info Card
              Card(
                color: getCardColor(context),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.listing.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: getLabelColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'LKR ${widget.listing.price.toStringAsFixed(2)} per month',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information Section
              Text(
                'Personal Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getLabelColor(context),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: getLabelColor(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: getInputFillColor(context),
                  prefixIcon: Icon(Icons.person, color: getSecondaryTextColor(context)),
                ),
                style: TextStyle(color: getLabelColor(context)),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your full name' : null,
                onSaved: (value) => _fullName = value!,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: getLabelColor(context)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: getInputFillColor(context),
                    prefixIcon: Icon(Icons.calendar_today, color: getSecondaryTextColor(context)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_dob.day.toString().padLeft(2, '0')}/${_dob.month.toString().padLeft(2, '0')}/${_dob.year}',
                        style: TextStyle(fontSize: 16, color: getLabelColor(context)),
                      ),
                      Icon(Icons.arrow_drop_down, color: getSecondaryTextColor(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: getLabelColor(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: getInputFillColor(context),
                  prefixIcon: Icon(Icons.email, color: getSecondaryTextColor(context)),
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: getLabelColor(context)),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter your email';
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: getLabelColor(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: getInputFillColor(context),
                  prefixIcon: Icon(Icons.phone, color: getSecondaryTextColor(context)),
                  hintText: '07X XXX XXXX',
                  hintStyle: TextStyle(color: getSecondaryTextColor(context)),
                ),
                keyboardType: TextInputType.phone,
                style: TextStyle(color: getLabelColor(context)),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter your phone number';
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value!)) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
                onSaved: (value) => _phone = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: getLabelColor(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: getInputFillColor(context),
                  prefixIcon: Icon(Icons.home, color: getSecondaryTextColor(context)),
                ),
                style: TextStyle(color: getLabelColor(context)),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your address' : null,
                onSaved: (value) => _address = value!,
              ),
              const SizedBox(height: 24),

              // Employment Information Section
              Text(
                'Employment Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getLabelColor(context),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Job Title',
                  labelStyle: TextStyle(color: getLabelColor(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: getInputFillColor(context),
                  prefixIcon: Icon(Icons.work, color: getSecondaryTextColor(context)),
                ),
                style: TextStyle(color: getLabelColor(context)),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your job title' : null,
                onSaved: (value) => _jobTitle = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Employment Status',
                  labelStyle: TextStyle(color: getLabelColor(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: getInputFillColor(context),
                  prefixIcon: Icon(Icons.business_center, color: getSecondaryTextColor(context)),
                  hintText: 'e.g. Full-time, Part-time, Self-employed',
                  hintStyle: TextStyle(color: getSecondaryTextColor(context)),
                ),
                style: TextStyle(color: getLabelColor(context)),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your employment status' : null,
                onSaved: (value) => _employmentStatus = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Monthly Income (LKR)',
                  labelStyle: TextStyle(color: getLabelColor(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: getInputFillColor(context),
                  prefixIcon: Icon(Icons.attach_money, color: getSecondaryTextColor(context)),
                  suffixText: 'LKR',
                  suffixStyle: TextStyle(color: getSecondaryTextColor(context)),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: getLabelColor(context)),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter your monthly income';
                  final income = double.tryParse(value!);
                  if (income == null || income <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) => _monthlyIncome = double.tryParse(value!) ?? 0.0,
              ),
              const SizedBox(height: 24),

              // Salary Slip Upload Section
              Text(
                'Proof of Income',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getLabelColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a clear photo of your latest salary slip',
                style: TextStyle(color: getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _pickSalarySlip,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(
                    color: _salarySlip == null
                        ? theme.colorScheme.primary
                        : getSecondaryTextColor(context),
                  ),
                  backgroundColor: theme.brightness == Brightness.dark
                      ? const Color(0xFF22242A)
                      : Colors.white,
                  foregroundColor: getLabelColor(context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload, color: getLabelColor(context)),
                    const SizedBox(width: 8),
                    Text(
                      'Upload Salary Slip',
                      style: TextStyle(
                        color: getLabelColor(context),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_salarySlip != null)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      _salarySlip!.path.split('/').last,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _salarySlip!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Request',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'By submitting, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: getSecondaryTextColor(context),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
