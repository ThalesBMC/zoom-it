#!/bin/bash

echo "🧹 Limpando ZoomIt completamente..."

# Mata o app se estiver rodando
pkill -9 ZoomIt 2>/dev/null

# Limpa UserDefaults/Preferences
defaults delete com.thales.zoomit 2>/dev/null
rm -rf ~/Library/Preferences/com.thales.zoomit.plist 2>/dev/null
rm -rf ~/Library/Preferences/com.thales.zoomit* 2>/dev/null

# Limpa Containers (se existir)
rm -rf ~/Library/Containers/com.thales.zoomit 2>/dev/null

# Reseta permissões de Screen Recording
tccutil reset ScreenCapture com.thales.zoomit 2>/dev/null

# Recarrega o daemon de preferências
killall cfprefsd 2>/dev/null

# Limpa DerivedData do Xcode (opcional - descomente se quiser)
# rm -rf ~/Library/Developer/Xcode/DerivedData/ZoomIt-* 2>/dev/null

echo "✅ ZoomIt limpo! Agora rode o app como se fosse a primeira vez."
echo ""
echo "📋 Próximos passos:"
echo "   1. Rode o app no Xcode (Cmd+R)"
echo "   2. O onboarding vai aparecer"
echo "   3. Quando tentar dar zoom, o macOS vai pedir permissão de Screen Recording"

