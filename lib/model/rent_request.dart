class RentRequest {
  final String? id;
  final String userId;
  final String listingId;
  final String status;
  final String fullName;
  final DateTime dob;
  final String email;
  final String phone;
  final String address;
  final String jobTitle;
  final String employmentStatus;
  final double monthlyIncome;
  final String salarySlipPath;

  RentRequest({
    this.id,
    required this.userId,
    required this.listingId,
    required this.status,
    required this.fullName,
    required this.dob,
    required this.email,
    required this.phone,
    required this.address,
    required this.jobTitle,
    required this.employmentStatus,
    required this.monthlyIncome,
    required this.salarySlipPath,
  });

  factory RentRequest.fromJson(Map<String, dynamic> json) {
    return RentRequest(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      listingId: json['listing_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      fullName: json['full_name']?.toString() ?? '',
      dob: DateTime.parse(json['dob']),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      jobTitle: json['job_title']?.toString() ?? '',
      employmentStatus: json['employment_status']?.toString() ?? '',
      monthlyIncome:
          (json['monthly_income'] is String)
              ? double.tryParse(json['monthly_income']) ?? 0.0
              : (json['monthly_income']?.toDouble() ?? 0.0),
      salarySlipPath: json['salary_slip']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'listing_id': listingId,
      'status': status,
      'full_name': fullName,
      'dob': dob.toIso8601String(),
      'email': email,
      'phone': phone,
      'address': address,
      'job_title': jobTitle,
      'employment_status': employmentStatus,
      'monthly_income': monthlyIncome,
      'salary_slip': salarySlipPath,
    };
  }
}
