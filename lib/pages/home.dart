import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const ScientificCalculator(),
    const BMICalculator(),
    const AgeCalculator(),
    const UnitConverter(),
    const LoanCalculator(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6B73FF),
            ],
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              HapticFeedback.lightImpact();
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF667eea),
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate),
                label: 'Calculator',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.monitor_weight),
                label: 'BMI',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cake),
                label: 'Age',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: 'Convert',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance),
                label: 'Loan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScientificCalculator extends StatefulWidget {
  const ScientificCalculator({super.key});

  @override
  State<ScientificCalculator> createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator>
    with TickerProviderStateMixin {
  String _display = '0';
  String _expression = '';
  double _result = 0;
  String _operation = '';
  double _operand = 0;
  bool _shouldResetDisplay = false;
  bool _isAdvancedMode = false;
  List<String> _history = [];

  late AnimationController _displayAnimationController;
  late Animation<double> _displayAnimation;

  @override
  void initState() {
    super.initState();
    _displayAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _displayAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _displayAnimationController, curve: Curves.easeOut),
    );
    _displayAnimationController.forward();
  }

  @override
  void dispose() {
    _displayAnimationController.dispose();
    super.dispose();
  }

  void _onButtonPressed(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      try {
        switch (value) {
          case 'C':
            _clear();
            break;
          case '±':
            _toggleSign();
            break;
          case '%':
            _percentage();
            break;
          case '=':
            _calculate();
            break;
          case '.':
            _addDecimal();
            break;
          case '+':
          case '-':
          case '*':
          case '/':
            _setOperation(value);
            break;
          case 'sin':
          case 'cos':
          case 'tan':
            _trigFunction(value);
            break;
          case 'ln':
            _logarithm();
            break;
          case 'log':
            _logarithmBase10();
            break;
          case 'x²':
            _square();
            break;
          case 'x³':
            _cube();
            break;
          case '√':
            _squareRoot();
            break;
          case 'xʸ':
            _setOperation('^');
            break;
          case '1/x':
            _reciprocal();
            break;
          case 'π':
            _addConstant(math.pi);
            break;
          case 'e':
            _addConstant(math.e);
            break;
          case 'MODE':
            _toggleMode();
            break;
          case 'HIST':
            _showHistory();
            break;
          default:
            _inputNumber(value);
        }
      } catch (e) {
        _display = 'Error';
        _shouldResetDisplay = true;
      }
    });
  }

  void _clear() {
    _display = '0';
    _expression = '';
    _result = 0;
    _operation = '';
    _operand = 0;
    _shouldResetDisplay = false;
  }

  void _toggleSign() {
    if (_display != '0' && _display != 'Error') {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    }
  }

  void _percentage() {
    try {
      double value = double.parse(_display);
      _display = _formatResult(value / 100);
      _shouldResetDisplay = true;
    } catch (e) {
      _display = 'Error';
      _shouldResetDisplay = true;
    }
  }

  void _addDecimal() {
    if (!_display.contains('.')) {
      _display += '.';
    }
  }

  void _inputNumber(String number) {
    if (_shouldResetDisplay || _display == '0' || _display == 'Error') {
      _display = number;
      _shouldResetDisplay = false;
    } else {
      _display += number;
    }
  }

  void _setOperation(String op) {
    try {
      if (_operation.isNotEmpty) {
        _calculate();
      }
      _operation = op;
      _operand = double.parse(_display);
      _expression = '$_display $op';
      _shouldResetDisplay = true;
    } catch (e) {
      _display = 'Error';
      _shouldResetDisplay = true;
    }
  }

  void _calculate() {
    try {
      if (_operation.isEmpty) return;

      double currentValue = double.parse(_display);
      String calculation = '$_expression $currentValue';
      
      switch (_operation) {
        case '+':
          _result = _operand + currentValue;
          break;
        case '-':
          _result = _operand - currentValue;
          break;
        case '*':
          _result = _operand * currentValue;
          break;
        case '/':
          if (currentValue != 0) {
            _result = _operand / currentValue;
          } else {
            _display = 'Error';
            _operation = '';
            return;
          }
          break;
        case '^':
          _result = math.pow(_operand, currentValue).toDouble();
          break;
      }

      _display = _formatResult(_result);
      _history.add('$calculation = $_display');
      if (_history.length > 10) _history.removeAt(0);
      _expression = '';
      _operation = '';
      _shouldResetDisplay = true;
    } catch (e) {
      _display = 'Error';
      _shouldResetDisplay = true;
    }
  }

  void _trigFunction(String func) {
    try {
      double value = double.parse(_display);
      double radians = value * (math.pi / 180);
      
      switch (func) {
        case 'sin':
          _result = math.sin(radians);
          break;
        case 'cos':
          _result = math.cos(radians);
          break;
        case 'tan':
          _result = math.tan(radians);
          break;
      }
      
      _display = _formatResult(_result);
      _history.add('$func($value°) = $_display');
      if (_history.length > 10) _history.removeAt(0);
      _shouldResetDisplay = true;
    } catch (e) {
      _display = 'Error';
      _shouldResetDisplay = true;
    }
  }

  void _logarithm() {
    try {
      double value = double.parse(_display);
      if (value > 0) {
        _result = math.log(value);
        _display = _formatResult(_result);
        _history.add('ln($value) = $_display');
        if (_history.length > 10) _history.removeAt(0);
      } else {
        _display = 'Error';
      }
      _shouldResetDisplay = true;
    } catch (e) {
      _display = 'Error';
      _shouldResetDisplay = true;
    }
  }

  void _logarithmBase10() {
    try {
      double value = double.parse(_display);
      if (value > 0) {
        _result = math.log(value) / math.log(10);
        _display = _formatResult(_result);
        _history.add('log($value) = $_display');
        if (_history.length > 10) _history.removeAt(0);
      } else {
        _display = 'Error';
      }
      _shouldResetDisplay = true;
    } catch (e) {
      _display = 'Error';
      _shouldResetDisplay = true;
    }
  }

  void _square() {
    try {
      double value = double.parse(_display);
      _result = value * value;
      _display = _formatResult(_result);
      _history.add('$value² = $_display');
      if (_history.length > 10) _history.removeAt(0);
      _shouldResetDisplay = true;
    } catch (e) {
      _display = 'Error';
      _shouldResetDisplay = true;
    }
  }

  void _cube() {
    try {
      double value = double.parse(_display);
      _result = value * value * value;
      _display = _formatResult(_result);
      _history.add('$value³ = $_display');
      if (_history.length > 10) _history.removeAt(0);
      _shouldResetDisplay = true;
    } catch (e) {
      _display = 'Error';
      _shouldResetDisplay = true;
    }
  }

  void _squareRoot() {
    try {
      double value = double.parse(_display);
      if (value >= 0) {
        _result = math.sqrt(value);
        _display = _formatResult(_result);
        _history.add('√$value = $_display');
        if (_history.length > 10) _history.removeAt(0);
      } else {
        _display = 'Error';
      }
      _shouldResetDisplay = true;
    } catch (e) {
      _display = 'Error';
      _shouldResetDisplay = true;
    }
  }

  void _reciprocal() {
    try {
      double value = double.parse(_display);
      if (value != 0) {
        _result = 1 / value;
        _display = _formatResult(_result);
        _history.add('1/$value = $_display');
        if (_history.length > 10) _history.removeAt(0);
      } else {
        _display = 'Error';
      }
      _shouldResetDisplay = true;
    } catch (e) {
      _display = 'Error';
      _shouldResetDisplay = true;
    }
  }

  void _addConstant(double constant) {
    _display = _formatResult(constant);
    _shouldResetDisplay = true;
  }

  void _toggleMode() {
    _isAdvancedMode = !_isAdvancedMode;
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _history.clear();
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.clear_all),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_history[index]),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatResult(double result) {
    if (result.isNaN || result.isInfinite) {
      return 'Error';
    }
    if (result == result.roundToDouble()) {
      return result.round().toString();
    }
    return result.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Calculator',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _onButtonPressed('HIST'),
                      icon: const Icon(Icons.history, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () => _onButtonPressed('MODE'),
                      icon: Icon(
                        _isAdvancedMode ? Icons.science : Icons.calculate,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_expression.isNotEmpty)
                  AnimatedOpacity(
                    opacity: _expression.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _expression,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _displayAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _displayAnimation.value,
                      child: Text(
                        _display,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Buttons
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: _isAdvancedMode ? _buildAdvancedCalculator() : _buildBasicCalculator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicCalculator() {
    return Column(
      children: [
        _buildButtonRow(['C', '±', '%', '/']),
        _buildButtonRow(['7', '8', '9', '*']),
        _buildButtonRow(['4', '5', '6', '-']),
        _buildButtonRow(['1', '2', '3', '+']),
        _buildButtonRow(['0', '.', '='], lastRow: true),
      ],
    );
  }

  Widget _buildAdvancedCalculator() {
    return Column(
      children: [
        _buildButtonRow(['C', '±', '%', '/', 'sin']),
        _buildButtonRow(['7', '8', '9', '*', 'cos']),
        _buildButtonRow(['4', '5', '6', '-', 'tan']),
        _buildButtonRow(['1', '2', '3', '+', 'ln']),
        _buildButtonRow(['0', '.', '=', 'log', 'π']),
        _buildButtonRow(['x²', 'x³', '√', 'xʸ', '1/x']),
        _buildButtonRow(['e'], lastRow: true),
      ],
    );
  }

  Widget _buildButtonRow(List<String> buttons, {bool lastRow = false}) {
    return Expanded(
      child: Row(
        children: buttons.map((button) {
          return _buildButton(button, lastRow && button == '0');
        }).toList(),
      ),
    );
  }

  Widget _buildButton(String text, [bool isWide = false]) {
    return Expanded(
      flex: isWide ? 2 : 1,
      child: Container(
        margin: const EdgeInsets.all(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getButtonGradient(text),
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getButtonColor(text).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _onButtonPressed(text),
              child: Container(
                height: 60,
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: _getFontSize(text),
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(text),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getButtonGradient(String text) {
    Color baseColor = _getButtonColor(text);
    return [
      baseColor.withOpacity(0.8),
      baseColor,
    ];
  }

  Color _getButtonColor(String text) {
    if (text == 'C' || text == '±' || text == '%') {
      return Colors.orange[400]!;
    } else if (['+', '-', '*', '/', '=', 'xʸ'].contains(text)) {
      return Colors.blue[500]!;
    } else if (['sin', 'cos', 'tan', 'ln', 'log', 'x²', 'x³', '√', '1/x', 'π', 'e'].contains(text)) {
      return Colors.purple[400]!;
    } else {
      return Colors.white.withOpacity(0.2);
    }
  }

  Color _getTextColor(String text) {
    if (text == 'C' || text == '±' || text == '%' || 
        ['+', '-', '*', '/', '=', 'xʸ'].contains(text) ||
        ['sin', 'cos', 'tan', 'ln', 'log', 'x²', 'x³', '√', '1/x', 'π', 'e'].contains(text)) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  double _getFontSize(String text) {
    if (['sin', 'cos', 'tan', 'ln', 'log', 'x²', 'x³', '√', 'xʸ', '1/x'].contains(text)) {
      return 16;
    }
    return 24;
  }
}

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  double _height = 170;
  double _weight = 70;
  double _bmi = 0;
  String _category = '';

  void _calculateBMI() {
    setState(() {
      _bmi = _weight / ((_height / 100) * (_height / 100));
      if (_bmi < 18.5) {
        _category = 'Underweight';
      } else if (_bmi < 25) {
        _category = 'Normal';
      } else if (_bmi < 30) {
        _category = 'Overweight';
      } else {
        _category = 'Obese';
      }
    });
  }

  Color _getCategoryColor() {
    switch (_category) {
      case 'Underweight':
        return Colors.blue;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BMI Calculator',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Height',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_height.round()} cm',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _height,
                    min: 100,
                    max: 220,
                    divisions: 120,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withOpacity(0.3),
                    onChanged: (value) {
                      setState(() {
                        _height = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Weight',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_weight.round()} kg',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _weight,
                    min: 30,
                    max: 150,
                    divisions: 120,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withOpacity(0.3),
                    onChanged: (value) {
                      setState(() {
                        _weight = value;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculateBMI,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF667eea),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Calculate BMI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_bmi > 0) ...[
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your BMI',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _bmi.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getCategoryColor()),
                      ),
                      child: Text(
                        _category,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AgeCalculator extends StatefulWidget {
  const AgeCalculator({super.key});

  @override
  State<AgeCalculator> createState() => _AgeCalculatorState();
}

class _AgeCalculatorState extends State<AgeCalculator> {
  DateTime _selectedDate = DateTime.now();
  int _years = 0;
  int _months = 0;
  int _days = 0;
  int _totalDays = 0;
  int _totalHours = 0;
  int _totalMinutes = 0;

  void _calculateAge() {
    final now = DateTime.now();
    final difference = now.difference(_selectedDate);
    
    setState(() {
      _totalDays = difference.inDays;
      _totalHours = difference.inHours;
      _totalMinutes = difference.inMinutes;
      
      // Calculate years, months, and days
      _years = now.year - _selectedDate.year;
      _months = now.month - _selectedDate.month;
      _days = now.day - _selectedDate.day;
      
      if (_days < 0) {
        _months--;
        _days += DateTime(now.year, now.month, 0).day;
      }
      
      if (_months < 0) {
        _years--;
        _months += 12;
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _calculateAge();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Age Calculator',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Select Your Birth Date',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculateAge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF667eea),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Calculate Age',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_totalDays > 0) ...[
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Age',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAgeCard('Years', _years.toString()),
                        _buildAgeCard('Months', _months.toString()),
                        _buildAgeCard('Days', _days.toString()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white30),
                    const SizedBox(height: 20),
                    _buildStatRow('Total Days', _totalDays.toString()),
                    _buildStatRow('Total Hours', _totalHours.toString()),
                    _buildStatRow('Total Minutes', _totalMinutes.toString()),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAgeCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class UnitConverter extends StatefulWidget {
  const UnitConverter({super.key});

  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  String _selectedCategory = 'Length';
  String _fromUnit = 'Meter';
  String _toUnit = 'Kilometer';
  double _inputValue = 1.0;
  double _outputValue = 0.001;

  final Map<String, Map<String, double>> _conversions = {
    'Length': {
      'Meter': 1.0,
      'Kilometer': 0.001,
      'Centimeter': 100.0,
      'Millimeter': 1000.0,
      'Inch': 39.3701,
      'Foot': 3.28084,
      'Yard': 1.09361,
      'Mile': 0.000621371,
    },
    'Weight': {
      'Kilogram': 1.0,
      'Gram': 1000.0,
      'Pound': 2.20462,
      'Ounce': 35.274,
      'Ton': 0.001,
    },
    'Temperature': {
      'Celsius': 1.0,
      'Fahrenheit': 33.8,
      'Kelvin': 274.15,
    },
    'Area': {
      'Square Meter': 1.0,
      'Square Kilometer': 0.000001,
      'Square Centimeter': 10000.0,
      'Square Foot': 10.7639,
      'Square Inch': 1550.0,
      'Acre': 0.000247105,
    },
  };

  void _convert() {
    setState(() {
      if (_selectedCategory == 'Temperature') {
        _outputValue = _convertTemperature(_inputValue, _fromUnit, _toUnit);
      } else {
        double baseValue = _inputValue / _conversions[_selectedCategory]![_fromUnit]!;
        _outputValue = baseValue * _conversions[_selectedCategory]![_toUnit]!;
      }
    });
  }

  double _convertTemperature(double value, String from, String to) {
    // Convert to Celsius first
    double celsius = value;
    if (from == 'Fahrenheit') {
      celsius = (value - 32) * 5 / 9;
    } else if (from == 'Kelvin') {
      celsius = value - 273.15;
    }

    // Convert from Celsius to target
    if (to == 'Fahrenheit') {
      return celsius * 9 / 5 + 32;
    } else if (to == 'Kelvin') {
      return celsius + 273.15;
    }
    return celsius;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unit Converter',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: const Color(0xFF667eea),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    items: _conversions.keys.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                        _fromUnit = _conversions[_selectedCategory]!.keys.first;
                        _toUnit = _conversions[_selectedCategory]!.keys.last;
                      });
                      _convert();
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: _inputValue.toString(),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Enter Value',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      _inputValue = double.tryParse(value) ?? 0.0;
                      _convert();
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _fromUnit,
                          dropdownColor: const Color(0xFF667eea),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'From',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          items: _conversions[_selectedCategory]!.keys.map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _fromUnit = newValue!;
                            });
                            _convert();
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _toUnit,
                          dropdownColor: const Color(0xFF667eea),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'To',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          items: _conversions[_selectedCategory]!.keys.map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _toUnit = newValue!;
                            });
                            _convert();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Result',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _outputValue.toStringAsFixed(6),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _toUnit,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoanCalculator extends StatefulWidget {
  const LoanCalculator({super.key});

  @override
  State<LoanCalculator> createState() => _LoanCalculatorState();
}

class _LoanCalculatorState extends State<LoanCalculator> {
  double _loanAmount = 100000;
  double _interestRate = 5.0;
  double _loanTerm = 30;
  double _monthlyPayment = 0;
  double _totalInterest = 0;
  double _totalAmount = 0;

  void _calculateLoan() {
    setState(() {
      double monthlyRate = _interestRate / 100 / 12;
      double numberOfPayments = _loanTerm * 12;
      
      if (monthlyRate > 0) {
        _monthlyPayment = _loanAmount * 
            (monthlyRate * math.pow(1 + monthlyRate, numberOfPayments)) /
            (math.pow(1 + monthlyRate, numberOfPayments) - 1);
      } else {
        _monthlyPayment = _loanAmount / numberOfPayments;
      }
      
      _totalAmount = _monthlyPayment * numberOfPayments;
      _totalInterest = _totalAmount - _loanAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan Calculator',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildSlider('Loan Amount', _loanAmount, 10000, 1000000, (value) {
                    setState(() {
                      _loanAmount = value;
                    });
                  }, '\$'),
                  _buildSlider('Interest Rate', _interestRate, 0.1, 20.0, (value) {
                    setState(() {
                      _interestRate = value;
                    });
                  }, '%'),
                  _buildSlider('Loan Term', _loanTerm, 1, 50, (value) {
                    setState(() {
                      _loanTerm = value;
                    });
                  }, ' years'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculateLoan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF667eea),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Calculate Loan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_monthlyPayment > 0) ...[
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Loan Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildResultRow('Monthly Payment', '\${_monthlyPayment.toStringAsFixed(2)}'),
                    _buildResultRow('Total Interest', '\${_totalInterest.toStringAsFixed(2)}'),
                    _buildResultRow('Total Amount', '\${_totalAmount.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, 
      Function(double) onChanged, String suffix) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(value < 10 ? 1 : 0)}$suffix',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 100,
          activeColor: Colors.white,
          inactiveColor: Colors.white.withOpacity(0.3),
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}