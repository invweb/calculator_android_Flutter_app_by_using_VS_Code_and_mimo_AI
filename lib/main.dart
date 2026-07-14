import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetInput = false;

  void _onDigitPressed(String digit) {
    setState(() {
      if (_shouldResetInput) {
        _expression = '';
        _shouldResetInput = false;
      }
      if (digit == '.' && _expression.contains('.')) return;
      if (_expression == '0' && digit != '.') {
        _expression = digit;
      } else {
        _expression += digit;
      }
    });
  }

  void _onOperatorPressed(String operator) {
    setState(() {
      if (_firstOperand != null && _operator != null && _expression.isNotEmpty) {
        _calculate();
      } else {
        _firstOperand = double.tryParse(_expression);
      }
      _operator = operator;
      _shouldResetInput = true;
    });
  }

  void _onEqualsPressed() {
    setState(() {
      if (_firstOperand != null && _operator != null && _expression.isNotEmpty) {
        _calculate();
        _operator = null;
        _firstOperand = null;
        _shouldResetInput = true;
      }
    });
  }

  void _calculate() {
    final secondOperand = double.tryParse(_expression);
    if (secondOperand == null || _firstOperand == null) return;

    double res;
    switch (_operator) {
      case '+':
        res = _firstOperand! + secondOperand;
        break;
      case '-':
        res = _firstOperand! - secondOperand;
        break;
      case '×':
        res = _firstOperand! * secondOperand;
        break;
      case '÷':
        if (secondOperand == 0) {
          _result = 'Error';
          return;
        }
        res = _firstOperand! / secondOperand;
        break;
      default:
        return;
    }

    if (res == res.roundToDouble() && res.abs() < 1e15) {
      _result = res.toInt().toString();
    } else {
      _result = res.toStringAsFixed(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    _expression = _result;
  }

  void _onClear() {
    setState(() {
      _expression = '';
      _result = '0';
      _firstOperand = null;
      _operator = null;
      _shouldResetInput = false;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    });
  }

  void _onPercentPressed() {
    setState(() {
      final value = double.tryParse(_expression);
      if (value != null) {
        final result = value / 100;
        _expression = result.toString();
      }
    });
  }

  void _onToggleSign() {
    setState(() {
      if (_expression.isNotEmpty && _expression != '0') {
        if (_expression.startsWith('-')) {
          _expression = _expression.substring(1);
        } else {
          _expression = '-$_expression';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayExpression = _expression.isEmpty
        ? (_firstOperand != null
            ? '${_formatNumber(_firstOperand!)} $_operator'
            : '')
        : _expression;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (displayExpression.isNotEmpty)
                      Text(
                        displayExpression,
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _result,
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildRow(['AC', '±', '%', '÷'], isOperatorRow: true),
                    _buildRow(['7', '8', '9', '×']),
                    _buildRow(['4', '5', '6', '-']),
                    _buildRow(['1', '2', '3', '+']),
                    _buildRow(['0', '.', '=']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> buttons, {bool isOperatorRow = false}) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((btn) {
          final isOperator = ['÷', '×', '-', '+', '='].contains(btn);
          final isSpecial = ['AC', '±', '%'].contains(btn);
          final isZero = btn == '0';

          Color bgColor;
          Color textColor;
          double horizontalPadding = 0;

          if (isOperator) {
            bgColor = _operator == btn && _shouldResetInput
                ? Colors.white
                : const Color(0xFFFF9500);
            textColor = _operator == btn && _shouldResetInput
                ? const Color(0xFFFF9500)
                : Colors.white;
          } else if (isSpecial) {
            bgColor = const Color(0xFFA5A5A5);
            textColor = const Color(0xFF1C1C1E);
          } else {
            bgColor = const Color(0xFF333333);
            textColor = Colors.white;
          }

          return Expanded(
            flex: isZero ? 2 : 1,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () => _handleButton(btn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                ),
                child: Text(
                  btn,
                  style: TextStyle(
                    fontSize: isOperator || isSpecial ? 28 : 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleButton(String btn) {
    switch (btn) {
      case 'AC':
        _onClear();
        break;
      case '±':
        _onToggleSign();
        break;
      case '%':
        _onPercentPressed();
        break;
      case '=':
        _onEqualsPressed();
        break;
      case '÷':
      case '×':
      case '-':
      case '+':
        _onOperatorPressed(btn);
        break;
      default:
        _onDigitPressed(btn);
    }
  }

  String _formatNumber(double number) {
    if (number == number.roundToDouble() && number.abs() < 1e15) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
