import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'model.dart';
import 'mpw.dart';

class Sites extends StatefulWidget {
  const Sites({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SitesState();
}

class _SitesState extends State<Sites> {
  SiteModel siteModel = SiteModel("", "long", 1);

  @override
  Widget build(BuildContext context) {
    final Map<String, SiteModel> sites =
        MPWContainer.of(context)?.model.sites?.sites ?? {};

    final siteNames = sites.keys.toList().reversed.toList();

    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _templateController = TextEditingController();

    return Scaffold(
        body: Align(
      alignment: const AlignmentDirectional(0, 0),
      child: Container(
          width: 500,
          height: 500,
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                  flex: 6,
                  child: Scrollbar(
                      child: ListView.builder(
                          itemCount: sites.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            final siteName = siteNames[index];
                            return ListTile(
                              title: Text(
                                siteName,
                                key: Key(siteName),
                                textAlign: TextAlign.center,
                              ),
                              onTap: () {
                                print(index);
                                setState(() {
                                  siteModel.site = sites[siteName]!.site;
                                  _nameController.text = siteModel.site;
                                  siteModel.count = sites[siteName]!.count;
                                  siteModel.template = sites[siteName]!.template;
                                });
                              },
                            );
                          }))),
              const Spacer(),
              Flexible(
                  flex: 3,
                  child: SizedBox(
                    width: 240,
                    child: TextField(
                      controller: _nameController,
                      onChanged: (value) {
                        setState(() {
                          siteModel.site = value;
                        });
                      },
                    ),
                  )),
              const Spacer(),
              Flexible(
                  flex: 3,
                  child: SizedBox(
                    width: 240,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            flex: 3,
                            child: DropdownButton<String>(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                value: siteModel.template,
                                items: MPW.templates.keys
                                    .map((value) => DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    siteModel.template = value!;
                                  });
                                })),
                        const Spacer(),
                        Flexible(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: siteModel.count <= 1
                                        ? null
                                        : () {
                                            setState(() {
                                              siteModel.count--;
                                            });
                                          },
                                    icon: const Icon(
                                        Icons.remove_circle_outline)),
                                Text(siteModel.count.toString()),
                                IconButton(
                                    onPressed: siteModel.count >= 0xffffffff
                                        ? null
                                        : () {
                                            setState(() {
                                              siteModel.count++;
                                            });
                                          },
                                    icon: const Icon(Icons.add_circle_outline)),
                              ],
                            )),
                      ],
                    ),
                  )),
              const Spacer(),
              Flexible(
                  flex: 3,
                  child: FutureBuilder(
                      future: MPWContainer.of(context)!.generate(siteModel),
                      builder: (BuildContext buildContext,
                          AsyncSnapshot<String> asyncSnapshot) {
                        var text = asyncSnapshot.data ?? "";
                        return GestureDetector(
                            onTap: () {
                              setState(() {
                                MPWContainer.of(context)!.addSite(siteModel);
                                Clipboard.setData(ClipboardData(text: text));
                              });
                            },
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 40),
                            ));
                      })),
            ],
          )),
    ));
  }
}
