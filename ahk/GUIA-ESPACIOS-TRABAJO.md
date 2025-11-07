# 🎯 Guía Rápida - Espacios de Trabajo

## ¿Qué son los espacios de trabajo?

Los espacios de trabajo te permiten **guardar un snapshot de todas tus ventanas abiertas** y restaurarlas más tarde. Útil para:
- Guardar tu setup de programación
- Crear diferentes contextos de trabajo
- Restaurar rápidamente tu entorno después de reiniciar

## 📝 Cómo usar

### 1️⃣ Guardar un espacio de trabajo

1. Abre todas las aplicaciones y ventanas que quieras guardar
2. Presiona `Ctrl + Alt + S`
3. Escribe un nombre descriptivo (ej: "Trabajo-Dev", "Gaming", "Estudios")
4. ¡Listo! Se guardará automáticamente (sin notificaciones molestas)

### 2️⃣ Restaurar un espacio de trabajo

1. Presiona `Ctrl + Alt + O` (letra O, no cero)
2. Aparecerá un menú con todos tus espacios guardados
3. Haz clic en el espacio que quieres abrir
4. Las aplicaciones se abrirán automáticamente

### 3️⃣ Eliminar un espacio de trabajo

1. Presiona `Ctrl + Alt + O`
2. Selecciona "🗑️ Eliminar espacio..."
3. Escribe el nombre del espacio a eliminar

## 💡 Consejos

- **Nombres descriptivos**: Usa nombres claros como "Trabajo-Lunes" o "Proyecto-X"
- **No cierres aplicaciones**: El espacio guarda qué aplicaciones abrir, no sus estados internos
- **Archivo de respaldo**: Los espacios se guardan en `workspaces.json` en la carpeta de scripts

## ⌨️ Atajos Completos

| Atajo | Función |
|-------|---------|
| `Ctrl + Alt + S` | **S**ave - Guardar espacio actual |
| `Ctrl + Alt + O` | **O**pen - Abrir menú de espacios |
| `Ctrl + Shift + H` | **H**ide - Ocultar ventana |
| `Ctrl + Shift + L` | **L**ast - Restaurar última ventana |
| `Ctrl + Shift + M` | **M**enu - Ver ventanas ocultas |

## 📁 ¿Dónde se guardan?

Los espacios de trabajo se guardan en:
```
C:\Users\TU_USUARIO\.config\ahk\workspaces.json
```

Puedes hacer backup de este archivo para no perder tus espacios.

## ❓ Solución de problemas

**No aparecen mis espacios guardados**
- Verifica que existe el archivo `workspaces.json` en la carpeta del script
- Presiona `Ctrl + Alt + R` para recargar los scripts

**Las ventanas no se abren en la posición correcta**
- Esto es normal en la primera versión
- Se abrirán las aplicaciones pero en sus posiciones por defecto

**Una aplicación no se abre**
- Verifica que la aplicación no se haya desinstalado
- Algunas aplicaciones de Windows Store pueden no guardarse correctamente

---

¿Preguntas? Revisa el README completo en la carpeta `ahk/`
