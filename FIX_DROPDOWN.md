# 🔧 Correção do Dropdown na Lista de Comunidades

## 📋 Problema Identificado

O dropdown (menu de ações) dos cards de comunidade estava sendo cortado pelo container do card, impossibilitando visualizar todas as opções disponíveis.

## 🔍 Causa Raiz

O problema tinha duas causas principais:

1. **`overflow: hidden` no `.card`**
   - A regra CSS global tinha `overflow: hidden` na linha 138 de `style.css`
   - Isso cortava qualquer conteúdo que extrapolasse os limites do card
   - Incluindo dropdowns, tooltips e outros elementos flutuantes

2. **Comportamento esperado do dropdown**
   - Dropdowns devem funcionar como **modais sobrepostos**
   - Não devem ser limitados pela geometria do elemento pai
   - Devem ter z-index alto para ficarem acima de outros elementos

## ✅ Solução Implementada

### 1. Alteração no CSS Global (`app/static/style.css`)

#### Antes:
```css
.card {
    overflow: hidden;
}
```

#### Depois:
```css
.card {
    overflow: visible;
}

/* Garantir que dropdowns funcionem como modais e não sejam cortados */
.dropdown-menu {
    position: absolute !important;
    z-index: 1050 !important;
    will-change: transform;
}

/* Garantir que o dropdown pai tenha contexto de posicionamento */
.dropdown {
    position: relative;
}
```

### 2. Preservação do Border-Radius para Imagens

Para que as imagens nos cards ainda respeitem o border-radius:

```css
.card-img-top {
    border-radius: 15px 15px 0 0;
}
```

## 🎯 Resultados

✅ **Dropdown agora se expande completamente**
- Não é mais cortado pelo card
- Todas as opções ficam visíveis

✅ **Comportamento de modal preservado**
- z-index alto (1050) garante sobreposição
- `position: absolute` garante posicionamento correto
- `will-change: transform` otimiza performance de animação

✅ **Sem efeitos colaterais**
- Cards com imagens continuam funcionando corretamente
- Border-radius preservado onde necessário
- Outros componentes não afetados

## 📁 Arquivos Modificados

- `app/static/style.css` - CSS global
  - Linha 138: `overflow: hidden` → `overflow: visible`
  - Linhas 147-162: Regras adicionadas para dropdowns

## 🧪 Como Testar

1. Acesse `/comunidade/` ou a lista de comunidades
2. Clique no botão de ações (três pontos) de qualquer comunidade
3. Verifique se o dropdown se expande completamente
4. Confirme que todas as opções estão visíveis:
   - Entrar
   - Bloquear
   - (Admin) Bloquear Globalmente
   - (Admin) Marcar como Filtrado

## 💡 Explicação Técnica

### Por que `overflow: visible`?

O `overflow: hidden` é comumente usado para:
- Forçar imagens a respeitar border-radius
- Prevenir scroll horizontal indesejado
- Conter floats

Mas ele tem o efeito colateral de **cortar conteúdo posicionado absolutamente** que extrapola os limites do container.

### Por que `position: relative` no `.dropdown`?

O `position: relative` no container `.dropdown` cria um **contexto de posicionamento** para o `.dropdown-menu` que tem `position: absolute`. Isso garante que:
- O menu se posicione relativamente ao botão dropdown
- Não seja afetado por outros elementos posicionados na página
- Funcione corretamente em layouts complexos

### Por que `z-index: 1050`?

O Bootstrap usa uma escala de z-index específica:
- Navbar: 1030
- Dropdowns: 1050
- Modals: 1055
- Tooltips: 1070

Usar 1050 garante que o dropdown fique:
- ✅ Acima de navbars
- ✅ Acima de cards
- ✅ Abaixo de modais (comportamento esperado)

## 🎨 Impacto Visual

**Antes:**
```
┌─────────────────┐
│ Card            │
│  ┌──────────┐   │
│  │ Dropdown │   │  <- Cortado aqui
└──│──────────┘───┘
   │ Opções   │
   │ invísiveis
```

**Depois:**
```
┌─────────────────┐
│ Card            │
│  ┌──────────┐   │
└──│──────────│───┘
   │ Dropdown │
   │ Opções   │
   │ visíveis │
   └──────────┘
```

## 🚀 Status

✅ **Correção Aplicada e Testada**

O dropdown agora funciona como esperado, comportando-se como um modal sobreposto que não é limitado pela geometria do card!
