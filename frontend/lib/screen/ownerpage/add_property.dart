import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import '../../config.dart';
import '../Provider/propertyList.dart';
// import 'booking.dart';
// import 'dashboard.dart';

class AddPropertyForm extends StatefulWidget {
  final String? token;
  final String? role;
  final int? phone;

  AddPropertyForm({this.token, this.role, this.phone});

  @override
  _AddPropertyFormState createState() => _AddPropertyFormState();
}

final DateFormat formatter = DateFormat('yyyy-MM-dd');

class _AddPropertyFormState extends State<AddPropertyForm> {
  late String id;
  late String email;
  late String names;
  late int phone;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode("${widget.token}");
    id = jwtDecodedToken['_id'];
    email = jwtDecodedToken['email'];
    names = jwtDecodedToken['names'];
    phone = jwtDecodedToken['phone'];
    print(jwtDecodedToken);
    print("Addpage:${names}");
    // phone = jwtDecodedToken['phone'];
  }
  TextEditingController _propertyAddressController = TextEditingController();
  TextEditingController _propertyLocalityController = TextEditingController();
  TextEditingController _propertyRentController = TextEditingController();
  TextEditingController _bookingRemainingController = TextEditingController();
  TextEditingController _propertyImageController = TextEditingController(); 
  DateTime? _selectedDate;
  String _selectedPropertyType = 'home';
  int _selectedBalcony = 1;
  int _selectedBedroom = 1;
  File? _propertyImage;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    ).then((pickedDate) {
      if (pickedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a date')),
        );
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _selectImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedImage == null) {
        return;
      }

      setState(() {
        _propertyImage = File(pickedImage.path);
        _propertyImageController.text = pickedImage.path;
      });
      print('selected image path: ${pickedImage.path}');
      print('selected image file: $pickedImage');
    } catch (e) {
      print('Error selecting image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image. Please try again')),
      );
    }
  }

  void _submitForm() async {
    final String propertyAddress = _propertyAddressController.text;
    final String propertyLocality = _propertyLocalityController.text;
    final String propertyRent = _propertyRentController.text;
    final String bookingRemaining = _bookingRemainingController.text;
    final String propertyType = _selectedPropertyType;
    final String balconyCount = _selectedBalcony.toString();
    final String bedroomCount = _selectedBedroom.toString();
    final String propertyDate =
        _selectedDate != null ? formatter.format(_selectedDate!) : '';

    String imageBase64 = '';

    if (propertyAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter property address')),
      );
      return;
    }

    if (propertyLocality.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter property locality')),
      );
      return;
    }

    if (_propertyImage != null) {
      try {
        List<int> imageBytes = await _propertyImage!.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
      } catch (e) {
        print('Error converting image to base64: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image. Please try again.')),
        );
        return;
      }
    }

    if (propertyRent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter property rent')),
      );
      return;
    }

    if (propertyType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a property type')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    print(names);
    print(propertyAddress);
    print('Image Base64: $imageBase64');
    final Map<String, String> requestBody = {
  'propertyAddress': propertyAddress,
  'ownerId': id,
  'ownerName': names,
  'propertyLocality': propertyLocality,
  'propertyRent': propertyRent,
  'propertyType': propertyType,
  'propertyBalconyCount': balconyCount,
  'propertyBedroomCount': bedroomCount,
  'propertyDate': propertyDate,
};

final request = http.MultipartRequest('POST', Uri.parse(createProperty));

request.fields.addAll(requestBody);

if (_propertyImage != null) {
  final fileStream = http.ByteStream(Stream.castFrom(_propertyImage!.openRead()));
  final fileLength = await _propertyImage!.length();

  final multipartFile = http.MultipartFile(
    'propertyImageBase64',
    fileStream,
    fileLength,
    filename: _propertyImage!.path.split('/').last,
    contentType: MediaType('image', 'png'), // Replace with the correct image content type
  );

  request.files.add(multipartFile);
}

final response = await http.Response.fromStream(await request.send());

print('Response status: ${response.statusCode}');
print('Response body: ${response.body}');


    if (response.statusCode == 201) {
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        try {
          await Provider.of<PropertyListProvider>(context, listen: false)
              .refreshData();
        } catch (e) {
          throw (e);
        }
        // String names = jsonResponse['names'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Property successfully added'),
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pop(context);
        // Navigator.pushNamed(
        //   context,
        //   'dashboard',
        //   arguments: {
        //     'token': widget.token!,
        //     'role': widget.role!,
        //     // 'names': names,
        //     'phone': widget.phone,
        //   },
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add prop')),
        );
      }
    } else {
      print('Server responded with status code ${response.statusCode}');
    }
  }

  Container _buildPropertyTypeContainer(
      String type, IconData iconData, bool isSelected) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Icon(
            iconData,
            size: 30.0,
            color: isSelected ? Color(0xFF764A9C) : Colors.grey,
          ),
          const SizedBox(height: 5.0),
          Text(
            type,
            style: TextStyle(
              color: isSelected ? Color(0xFF764A9C) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SizedBox(
          height: 30,
          child: Text(
            'Add Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Property Type',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPropertyType = 'home';
                      });
                    },
                    child: _buildPropertyTypeContainer(
                      'Home',
                      Icons.home,
                      _selectedPropertyType == 'home',
                    ),
                  ),
                  const SizedBox(width: 10.0),
                ],
              ),
              const SizedBox(height: 20.0),
              Text(
                'Property Details',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF764A9C).withOpacity(0.5),
                          width: 1.0,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: TextField(
                        controller: _propertyAddressController,
                        decoration: InputDecoration(
                          labelText: 'Property Address',
                          labelStyle: TextStyle(color: Color(0xFF764A9C)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF764A9C)
                              .withOpacity(0.5), // Purple border color
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white, // White background color
                      ),
                      child: TextField(
                        controller: _propertyLocalityController,
                        style:
                            TextStyle(color: Colors.black), // Black text color
                        decoration: InputDecoration(
                          labelText: 'Property Locality',
                          labelStyle: TextStyle(
                              color: Color(0xFF764A9C)), // Purple label color
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Text(
                "Balcony",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  int number = index + 0;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBalcony = number;
                      });
                    },
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedBalcony == number
                              ? Color(0xFF764A9C)
                              : Colors.grey,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Center(
                        child: Text(
                          number.toString(),
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: _selectedBalcony == number
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _selectedBalcony == number
                                ? Color(0xFF764A9C)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20.0),
              Text(
                "Bedrooms",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  int number = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBedroom = number;
                      });
                    },
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedBedroom == number
                              ? Color(0xFF764A9C)
                              : Colors.grey,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Center(
                        child: Text(
                          number.toString(),
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: _selectedBedroom == number
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _selectedBedroom == number
                                ? Color(0xFF764A9C)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Property Rent',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFF764A9C).withOpacity(0.5),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: TextField(
                  controller: _propertyRentController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Rent Amount',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Property Rented Date',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _selectedDate == null
                        ? 'No Date Selected'
                        : formatter.format(_selectedDate!),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _presentDatePicker,
                    icon: const Icon(
                      Icons.calendar_month,
                      size: 50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _selectImage,
                child: Text('Upload Image'),
              ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(12),
                  ),
                  onPressed: _submitForm,
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
