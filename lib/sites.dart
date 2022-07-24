import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'mpw.dart';

class SiteModel {
  String site;
  String template;
  int count;
  SiteModel(this.site, this.template, this.count);
}

class Sites extends StatefulWidget {
  const Sites({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SitesState();
}

class _SitesState extends State<Sites> {
  SiteModel siteModel = SiteModel("", "long", 1);
  TextEditingController edit = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
      alignment: const AlignmentDirectional(0, 0),
      child: Container(
          width: 500,
          height: 300,
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                  flex: 3,
                  child: SizedBox(
                    width: 220,
                    child: TextField(
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
                    width: 220,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            flex: 3,
                            child: DropdownButton<String>(
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
                            edit.text = asyncSnapshot.data ?? "";
                        return TextField(
                          readOnly: true,
                          textAlign: TextAlign.center,
                          controller: edit,
                          style: const TextStyle(fontSize: 40),
                          onTap: () {
                            edit.selection = TextSelection(baseOffset: 0, extentOffset: edit.text.length);
                            Clipboard.setData(ClipboardData(text: edit.text));
                          },
                        );
                      })),
            ],
          )),
    ));
  }
}
