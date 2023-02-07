import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_search/bloc/image_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_search/enum/image_size.dart';

class ImageAIScreen extends StatefulHookConsumerWidget {
  const ImageAIScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageAIScreenState();
}

class _ImageAIScreenState extends ConsumerState<ImageAIScreen> {
  final promptCon = TextEditingController();

  bool showResults = false;
  ImageSize size = ImageSize.size_1024x1024;
  int count = 4;

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(imageBloc).retrivedData;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image AI"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: promptCon,
                    onChanged: (val) {
                      setState(() {
                        showResults = false;
                      });
                    },
                    decoration:
                        const InputDecoration(label: Text("Enter Input Here")),
                  ),
                ),
                const SizedBox(width: 18),
                const Text('Image Count: '),
                DropdownButton(
                    alignment: Alignment.bottomCenter,
                    value: count,
                    isDense: true,
                    onChanged: (value) {
                      setState(() {
                        count = value ?? 4;
                      });
                    },
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: [
                      ...List.generate(
                        10,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        ),
                      )
                    ]),
                const SizedBox(width: 18),
                PopupMenuButton(
                  tooltip: 'Image Filter',
                  itemBuilder: (context) => [
                    ...List.generate(
                      ImageSize.values.length,
                      (index) {
                        return PopupMenuItem(
                          value: index,
                          onTap: () {
                            setState(() {
                              size = ImageSize.values[index];
                            });
                          },
                          child: Text(
                            ImageSizeFilter().filter(ImageSize.values[index]),
                            style: TextStyle(
                                fontWeight: size == ImageSize.values[index]
                                    ? FontWeight.w700
                                    : null,
                                color: size == ImageSize.values[index]
                                    ? Colors.green
                                    : null),
                          ),
                        );
                      },
                    )
                  ],
                  child: const Icon(Icons.image),
                ),
                const SizedBox(width: 18),
                GestureDetector(
                  onTap: () {
                    if (promptCon.text.isEmpty || promptCon.text.length < 5) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Put at least 5 letter query"),
                        behavior: SnackBarBehavior.floating,
                      ));
                    } else {
                      setState(() {
                        showResults = true;
                      });
                      ref.read(imageBloc).getImage(
                          prompt: promptCon.text,
                          imageSize: size,
                          imageCount: count);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      'Search',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: showResults,
              child: results.when(
                  data: (data) {
                    return Expanded(
                      child: GridView.custom(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          childrenDelegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  // context.router.push(ImageDetailViewRoute(
                                  //     images: contestant.images ?? [],
                                  //     index: index));
                                },
                                child: Image.network(
                                  data[index]['url'],
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              '${((loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : 0) * 100).toStringAsFixed(2)} %'),
                                          const SizedBox(height: 10),
                                          const CircularProgressIndicator
                                              .adaptive(),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                            childCount: data.length,
                          )),
                    );
                  },
                  error: (e, _) {
                    return Text(e.toString());
                  },
                  loading: () => const Center(
                        child: CircularProgressIndicator(),
                      )),
            )
          ],
        ),
      ),
    );
  }
}
