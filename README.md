# MindEase

Aplicativo mobile de gerenciamento de tarefas com foco em **acessibilidade cognitiva** para estudantes.

## Sobre o Projeto

- **Universidade:** FIAP
- **Curso:** Front End Engineering (Pos-Tech)
- **Atividade:** Hackathon
- **Aluno:** Danilo Moraes Ferreira

## Funcionalidades

- Gerenciamento de tarefas com status (A Fazer, Em Progresso, Concluido)
- Checklist dentro de cada tarefa
- Timer Pomodoro integrado
- 4 temas visuais (Calm, Alto Contraste, Dark Focus, Minimal)
- 3 niveis de complexidade da interface (Simples, Normal, Detalhado)
- Ajuste de tamanho de fonte e espacamento
- Modo foco e alertas cognitivos
- Perfil do usuario com exportacao/importacao de dados (JSON)
- Persistencia local com SharedPreferences

## Tecnologias

- Flutter / Dart
- Provider (gerenciamento de estado)
- Material Design 3
- SharedPreferences (persistencia local)

## Como Rodar

```bash
flutter pub get
flutter run -d chrome
```

Ou para dispositivo mobile:

```bash
flutter run
```

## Estrutura do Projeto

```
lib/
  main.dart
  models/          # Modelos de dados (Task, UserPreferences, UserProfile)
  providers/       # Providers (estado da aplicacao)
  screens/         # Telas (Tasks, Accessibility, Profile)
  services/        # Servico de persistencia local
  theme/           # Definicao de temas
  widgets/         # Widgets reutilizaveis
test/
  widget_test.dart # Testes unitarios dos modelos
```
