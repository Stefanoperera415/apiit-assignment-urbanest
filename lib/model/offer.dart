class Offer {
  final String? id;
  final String userId;
  final String listingId;
  final String fullName;
  final DateTime dob;
  final String email;
  final String phone;
  final double offerAmount;
  final String status; // pending, accepted, rejected
  final DateTime? createdAt;

  Offer({
    this.id,
    required this.userId,
    required this.listingId,
    required this.fullName,
    required this.dob,
    required this.email,
    required this.phone,
    required this.offerAmount,
    this.status = 'pending',
    this.createdAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      listingId: json['listing_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      dob: DateTime.parse(json['dob']),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      offerAmount:
          (json['offer_amount'] is String)
              ? double.tryParse(json['offer_amount']) ?? 0.0
              : (json['offer_amount']?.toDouble() ?? 0.0),
      status: json['status']?.toString() ?? 'pending',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'listing_id': listingId,
      'full_name': fullName,
      'dob': dob.toIso8601String(),
      'email': email,
      'phone': phone,
      'offer_amount': offerAmount,
      'status': status,
    };
  }
}
