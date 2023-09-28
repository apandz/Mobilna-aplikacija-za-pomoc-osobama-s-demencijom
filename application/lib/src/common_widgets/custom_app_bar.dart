import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/global_variables.dart';
import '../screens/settings/account.dart';
import '../screens/settings/settings.dart';

class CustomAppBar extends StatefulWidget {
  final Color color;
  final String text;
  final Screen screen;
  final Function? sortFunction;

  const CustomAppBar({
    super.key,
    required this.color,
    required this.text,
    required this.screen,
    this.sortFunction,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  Sort? selectedItem;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80.0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          icon: SizedBox(
            height: GlobalVariables.iconSize,
            width: GlobalVariables.iconSize,
            child: SvgPicture.asset(GlobalVariables.settingsIcon),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20.0),
        child: Container(
          height: 40.0,
          width: MediaQuery.of(context).size.width - 150.0,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10.0),
            ),
          ),
          child: Stack(
            children: [
              widget.screen != Screen.categories
                  ? Positioned(
                      left: 0.0,
                      top: 0.0,
                      bottom: 0.0,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: SizedBox(
                          height: GlobalVariables.iconSize3,
                          width: GlobalVariables.iconSize3,
                          child: SvgPicture.asset(GlobalVariables.backIcon),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              Center(
                child: SizedBox(
                  width: 160.0,
                  child: Text(
                    widget.text,
                    style: GlobalVariables.textStyle1.copyWith(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              widget.screen != Screen.other
                  ? Positioned(
                      right: 0.0,
                      top: 0.0,
                      bottom: 0.0,
                      child: PopupMenuButton<Sort>(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          elevation: 1.0,
                          initialValue: selectedItem,
                          onSelected: (Sort sort) {
                            setState(() {
                              selectedItem = sort;
                              widget.sortFunction!(sort);
                            });
                          },
                          icon: SizedBox(
                            height: GlobalVariables.iconSize2,
                            width: GlobalVariables.iconSize2,
                            child: SvgPicture.asset(GlobalVariables.sortIcon),
                          ),
                          itemBuilder: (BuildContext context) {
                            final list = [
                              PopupMenuItem<Sort>(
                                value: Sort.nameAsc,
                                child: Text(
                                    AppLocalizations.of(context)!.sortNameAToZ),
                              ),
                              PopupMenuItem<Sort>(
                                value: Sort.nameDesc,
                                child: Text(
                                    AppLocalizations.of(context)!.sortNameZToA),
                              ),
                            ];
                            if (widget.screen == Screen.itemsOther) {
                              list.add(
                                PopupMenuItem<Sort>(
                                    value: Sort.expirationDateAsc,
                                    child: Text(AppLocalizations.of(context)!
                                        .sortDateAToZ)),
                              );
                              list.add(
                                PopupMenuItem<Sort>(
                                    value: Sort.expirationDateDesc,
                                    child: Text(AppLocalizations.of(context)!
                                        .sortDateZToA)),
                              );
                            }
                            return list;
                          }),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountScreen(),
                ),
              );
            },
            icon: SizedBox(
              height: GlobalVariables.iconSize,
              width: GlobalVariables.iconSize,
              child: SvgPicture.asset(GlobalVariables.userIcon),
            ),
          ),
        ),
      ],
      backgroundColor: widget.color,
      shadowColor: Colors.transparent,
    );
  }
}
