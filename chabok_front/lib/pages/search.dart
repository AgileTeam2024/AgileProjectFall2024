import 'package:flutter/material.dart';

class SearchResultsPage extends StatefulWidget {
  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // Mock product list
  List<Map<String, dynamic>> products = [
    {
      'name': 'Product 1',
      'seller': 'Seller A',
      'price': 50,
      'status': 'Available'
    },
    {
      'name': 'Product 2',
      'seller': 'Seller B',
      'price': 30,
      'status': 'Reserved'
    },
    {
      'name': 'Product 3',
      'seller': 'Seller C',
      'price': 20,
      'status': 'Available'
    },
    {
      'name': 'Product 4',
      'seller': 'Seller A',
      'price': 70,
      'status': 'Available'
    },
    {
      'name': 'Product 5',
      'seller': 'Seller B',
      'price': 100,
      'status': 'Reserved'
    },
  ];

  String selectedCategory = 'All';
  RangeValues selectedPriceRange = RangeValues(0, 100);
  String selectedStatus = 'All';
  String sortOption = 'Recent';
  int currentPage = 1;
  final int itemsPerPage = 3;

  // Filtered product list
  List<Map<String, dynamic>> get filteredProducts {
    var filtered = products.where((product) {
      final matchesCategory =
          selectedCategory == 'All' || product['seller'] == selectedCategory;
      final matchesPrice = product['price'] >= selectedPriceRange.start &&
          product['price'] <= selectedPriceRange.end;
      final matchesStatus =
          selectedStatus == 'All' || product['status'] == selectedStatus;
      return matchesCategory && matchesPrice && matchesStatus;
    }).toList();

    // Sort products
    if (sortOption == 'Price') {
      filtered.sort((a, b) => a['price'].compareTo(b['price']));
    }
    return filtered;
  }

  // Paginated products
  List<Map<String, dynamic>> get paginatedProducts {
    final start = (currentPage - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    return filteredProducts.sublist(
        start, end > filteredProducts.length ? filteredProducts.length : end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800), // Limit width to 800px
          child: Column(
            children: [
              // Filters Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Filter
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items: ['All', 'Seller A', 'Seller B', 'Seller C']
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Category'),
                        ),
                        SizedBox(height: 10),

                        // Price Range Filter
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price Range:'),
                            RangeSlider(
                              values: selectedPriceRange,
                              min: 0,
                              max: 100,
                              divisions: 10,
                              labels: RangeLabels(
                                '\$${selectedPriceRange.start.toStringAsFixed(0)}',
                                '\$${selectedPriceRange.end.toStringAsFixed(0)}',
                              ),
                              onChanged: (values) {
                                setState(() {
                                  selectedPriceRange = values;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Status Filter
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          items: ['All', 'Available', 'Reserved']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Status'),
                        ),
                        SizedBox(height: 10),

                        // Sort Options
                        DropdownButtonFormField<String>(
                          value: sortOption,
                          items: ['Recent', 'Price']
                              .map((sort) => DropdownMenuItem(
                                    value: sort,
                                    child: Text(sort),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              sortOption = value!;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Sort By'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(),

              // Products List Section
              Expanded(
                child: ListView.builder(
                  itemCount: paginatedProducts.length,
                  itemBuilder: (context, index) {
                    final product = paginatedProducts[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Icon(Icons.shopping_bag,
                            size: 40, color: Colors.blueAccent),
                        title: Text(product['name']),
                        subtitle: Text(
                            'Seller: ${product['seller']}\nPrice: \$${product['price']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.visibility, color: Colors.blue),
                          onPressed: () {
                            // TODO: Navigate to product details page
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Pagination Section
              if (filteredProducts.length > itemsPerPage)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      (filteredProducts.length / itemsPerPage).ceil(),
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            currentPage = index + 1;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: currentPage == index + 1
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: currentPage == index + 1
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
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

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SearchResultsPage(),
  ));
}
