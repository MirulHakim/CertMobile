import 'package:flutter/material.dart';

class RepositoryPage extends StatelessWidget {
  const RepositoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repository'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RepositoryCard(
                      fileName: 'Certificate_${index + 1}.pdf',
                      fileSize: '${(index + 1) * 2.5} MB',
                      uploadDate:
                          DateTime.now().subtract(Duration(days: index * 7)),
                      fileType: index % 2 == 0 ? 'PDF' : 'Image',
                    ),
                  );
                },
                childCount: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RepositoryCard extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final DateTime uploadDate;
  final String fileType;

  const RepositoryCard({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.uploadDate,
    required this.fileType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Implement file preview/download
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: fileType == 'PDF'
                      ? Colors.red.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  fileType == 'PDF' ? Icons.picture_as_pdf : Icons.image,
                  color: fileType == 'PDF' ? Colors.red : Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Size: $fileSize • ${uploadDate.toString().split(' ')[0]}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Implement file options menu
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
