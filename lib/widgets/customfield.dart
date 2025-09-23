import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomField extends StatefulWidget {
  final String? label;
  final bool? enabled;
  final bool readOnly;
  final double? height;
  final double? width;
  final bool isCircular;
  final TextInputType? inputType;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final Function()? onTap;
  final int? maxLines;
  final int? minLines;
  final TextEditingController? controller;
  final int? maxLength;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final bool? isPasswordField;
  final Color? filledColor;
  final bool autoFocus;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  final EdgeInsets? spacing;
  final Function()? onSuffixTap;
  final void Function(String)? onChanged;
  final String? hint;
  final Color lineColor; // 👈 new property

  const CustomField({
    super.key,
    this.maxLength,
    this.readOnly = false,
    this.hint,
    this.width,
    this.isCircular = false,
    this.label,
    this.enabled,
    this.inputType,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.height,
    this.prefixWidget,
    this.suffixWidget,
    this.controller,
    this.maxLines,
    this.validator,
    this.inputFormatters,
    this.isRequired = true,
    this.isPasswordField,
    this.onSuffixTap,
    this.spacing,
    this.onChanged,
    this.filledColor,
    this.autoFocus = false,
    this.focusNode,
    this.minLines,
    this.textInputAction = TextInputAction.none,
    this.onFieldSubmitted,
    this.lineColor = Colors.yellow, // 👈 default is yellow
  });

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  late bool showHidePassword;
  BorderRadius fieldRad = BorderRadius.circular(10);

  @override
  void initState() {
    if (widget.isPasswordField != null) {
      showHidePassword = widget.isPasswordField!;
    } else {
      showHidePassword = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.spacing,
      child: TextFormField(
        cursorColor: widget.lineColor, // 👈 cursor matches line color
        onFieldSubmitted: widget.textInputAction == TextInputAction.next
            ? (_) => FocusScope.of(context).nextFocus()
            : widget.onFieldSubmitted,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        focusNode: widget.focusNode,
        autofocus: widget.autoFocus,
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        keyboardType: widget.isPasswordField != null
            ? TextInputType.visiblePassword
            : widget.inputType ?? TextInputType.text,
        onTap: widget.onTap,
        maxLength: widget.maxLength,
        obscureText: (widget.isPasswordField != null && showHidePassword),
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.textInputAction,
        validator: widget.isRequired
            ? (String? value) {
          return widget.validator == null ? null : widget.validator!(value);
        }
            : null,
        onChanged: widget.onChanged,
        maxLines: widget.maxLines ?? 1,
        minLines: widget.minLines,
        textAlign: TextAlign.start,
        controller: widget.controller,
        autovalidateMode: AutovalidateMode.disabled,
        decoration: InputDecoration(
          counterText: widget.maxLength?.toString(),
          isDense: true,
          labelText: widget.label,
          hintText: widget.hint,
          alignLabelWithHint: true,
          hintStyle: const TextStyle(color: Colors.white),
          labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          fillColor: widget.filledColor,
          filled: widget.filledColor != null,
          contentPadding: EdgeInsets.symmetric(
            vertical: widget.isCircular ? 15 : 10.0,
            horizontal: 10,
          ),

          // ✅ Border Handling
          border: widget.isCircular
              ? OutlineInputBorder(borderRadius: fieldRad)
              : const UnderlineInputBorder(),

          focusedBorder: widget.isCircular
              ? OutlineInputBorder(
            borderSide: BorderSide(color: widget.lineColor, width: 2),
            borderRadius: fieldRad,
          )
              : UnderlineInputBorder(
            borderSide: BorderSide(color: widget.lineColor, width: 2),
          ),

          enabledBorder: widget.isCircular
              ? OutlineInputBorder(
            borderSide: BorderSide(color: widget.lineColor, width: 1),
            borderRadius: fieldRad,
          )
              : UnderlineInputBorder(
            borderSide: BorderSide(color: widget.lineColor.withOpacity(0.7), width: 1),
          ),

          errorBorder: widget.isCircular
              ? OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: fieldRad,
          )
              : const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),

          disabledBorder: widget.isCircular
              ? OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: fieldRad,
          )
              : const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),

          // Password toggle / Suffix
          suffixIcon: (widget.isPasswordField != null)
              ? Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
            child: IconButton(
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  showHidePassword = !showHidePassword;
                });
              },
              icon: Icon(
                (showHidePassword)
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: widget.lineColor,
              ),
            ),
          )
              : widget.suffixWidget ?? const SizedBox.shrink(),

          prefixIconConstraints: BoxConstraints(
            minWidth: widget.prefixIcon != null || widget.prefixWidget != null ? 40 : 10,
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: widget.suffixIcon != null || widget.suffixWidget != null ? 40 : 10,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
            widget.prefixIcon,
            size: 25,
            color: widget.lineColor,
          )
              : widget.prefixWidget ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
