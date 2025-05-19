// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

//Packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';
import 'package:jcsd_flutter/backend/modules/services/services_data.dart';

//Pages
import 'package:jcsd_flutter/view/services/modals/unarchiveservice.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class ServicesArchivePage extends ConsumerStatefulWidget {
  const ServicesArchivePage({super.key});

  @override
  ConsumerState<ServicesArchivePage> createState() =>
      _ServicesArchivePageState();
}

class _ServicesArchivePageState extends ConsumerState<ServicesArchivePage> {
  _showUnarchiveServiceModal(ServicesData service, int serviceID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return UnarchiveServiceModal(
          serviceID: serviceID,
          servicesData: service,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(activePage: '/servicesArchive'),
          Expanded(
            child: Column(
              children: [
                const Header(
                  title: 'Archive List',
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildWebView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 350,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  color: Color(0xFFABABAB),
                  fontFamily: 'NunitoSans',
                ),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTable(context),
        ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final fetchServices = ref.watch(fetchHiddenServices);

    return fetchServices.when(
      data: (services) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeaderRow(),
              const Divider(height: 1, color: Colors.grey),
              Expanded(
                child: ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildServicesRow(services, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
      error: (err, stackTrace) =>
          Text('Error fetching data from services table: $err'),
      loading: () => const LinearProgressIndicator(
        backgroundColor: Color.fromRGBO(0, 134, 239, 1),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: const Color.fromRGBO(0, 174, 239, 1),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Service ID',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Service Name',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Minimum Price',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Service Price',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Actions',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesRow(List<ServicesData> services, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey[100] : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              services[index].serviceID.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              services[index].serviceName.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
            ),
          ),
          Expanded(
            child: Text(
              services[index].maxPrice.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                    onPressed: () => _showUnarchiveServiceModal(
                        services[index], services[index].serviceID),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 26, 118, 60),
                    ),
                    child: const Text(
                      'Unarchive',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
