import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _firstLogoController;
  late AnimationController _secondLogoController;
  late AnimationController _progressController;
  
  late Animation<double> _firstLogoFadeAnimation;
  late Animation<double> _firstLogoScaleAnimation;
  late Animation<double> _secondLogoFadeAnimation;
  late Animation<double> _secondLogoScaleAnimation;
  late Animation<double> _progressAnimation;
  
  bool _showFirstSplash = true;
  int _currentStep = 0;
  final List<String> _loadingSteps = [
    'Inicializando sistema...',
    'Conectando à base de dados...',
    'Carregando configurações...',
    'Preparando interface...',
    'Finalizando...'
  ];

  @override
  void initState() {
    super.initState();
    
    // Controlador para a primeira logo (Anteres)
    _firstLogoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Controlador para a segunda logo (business_center)
    _secondLogoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Controlador para o progresso
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Animações da primeira logo
    _firstLogoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _firstLogoController,
      curve: Curves.easeInOut,
    ));
    
    _firstLogoScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _firstLogoController,
      curve: Curves.elasticOut,
    ));
    
    // Animações da segunda logo
    _secondLogoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _secondLogoController,
      curve: Curves.easeInOut,
    ));
    
    _secondLogoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _secondLogoController,
      curve: Curves.elasticOut,
    ));
    
    // Animação do progresso
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // PRIMEIRA SPLASH - Logo Anteres (5 segundos)
    _firstLogoController.forward();
    
    await Future.delayed(const Duration(seconds: 5));
    
    // Transição para segunda splash
    setState(() {
      _showFirstSplash = false;
    });
    
    // SEGUNDA SPLASH - Business center com carregamento
    _secondLogoController.forward();
    
    // Inicia o progresso
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();
    
    // Simula carregamento com steps
    _simulateLoading();
    
    // Navega para a tela principal após mais 6 segundos
    Timer(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }
  
  void _simulateLoading() {
    Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (_currentStep < _loadingSteps.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _firstLogoController.dispose();
    _secondLogoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: _showFirstSplash ? _buildFirstSplash() : _buildSecondSplash(),
      ),
    );
  }

  // PRIMEIRA SPLASH - Logo Anteres limpa
  Widget _buildFirstSplash() {
    return Center(
      child: AnimatedBuilder(
        animation: _firstLogoController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _firstLogoFadeAnimation,
            child: ScaleTransition(
              scale: _firstLogoScaleAnimation,
              child: Container(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/antares.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.business_center,
                      size: 120,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // SEGUNDA SPLASH - Business center com carregamento
  Widget _buildSecondSplash() {
    return SafeArea(
      child: Column(
        children: [
          // Área principal com ícone business_center e textos
          Expanded(
            flex: 3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone business_center
                  AnimatedBuilder(
                    animation: _secondLogoController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _secondLogoFadeAnimation,
                        child: ScaleTransition(
                          scale: _secondLogoScaleAnimation,
                          child: Icon(
                            Icons.business_center,
                            size: 120,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Textos animados
                  AnimatedBuilder(
                    animation: _secondLogoController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _secondLogoFadeAnimation,
                        child: Column(
                          children: [
                            const Text(
                              'CONTROLE DE MATERIAIS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sistema de Gestão Integrada',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Área de carregamento
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Barra de progresso animada
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Texto de carregamento
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _loadingSteps[_currentStep],
                              key: ValueKey(_currentStep),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Indicador de progresso circular pequeno
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Rodapé com versão
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                Text(
                  'Versão 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 Antares - Todos os direitos reservados',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
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
