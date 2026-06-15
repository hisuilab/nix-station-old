# ============================================================
# asdf: asdf バージョン管理
# ============================================================
typeset -g POWERLEVEL9K_ASDF_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_BACKGROUND=$C_INDIGO

# バージョンソース (shell, local, global)
typeset -g POWERLEVEL9K_ASDF_SOURCES=(shell local global)
# グローバルと同じ場合は非表示
typeset -g POWERLEVEL9K_ASDF_PROMPT_ALWAYS_SHOW=false
# system の場合も表示
typeset -g POWERLEVEL9K_ASDF_SHOW_SYSTEM=true
# 特定ファイルがある場合のみ表示
typeset -g POWERLEVEL9K_ASDF_SHOW_ON_UPGLOB=

# 言語別の色設定
typeset -g POWERLEVEL9K_ASDF_RUBY_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_RUBY_BACKGROUND=$C_ERROR

typeset -g POWERLEVEL9K_ASDF_PYTHON_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_PYTHON_BACKGROUND=$C_INDIGO

typeset -g POWERLEVEL9K_ASDF_GOLANG_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_ASDF_GOLANG_BACKGROUND=$C_SUCCESS_ALT

typeset -g POWERLEVEL9K_ASDF_NODEJS_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_ASDF_NODEJS_BACKGROUND=$C_SUCCESS

typeset -g POWERLEVEL9K_ASDF_RUST_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_RUST_BACKGROUND=$C_NEON_PURPLE

typeset -g POWERLEVEL9K_ASDF_DOTNET_CORE_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_DOTNET_CORE_BACKGROUND=$C_NEON_PURPLE

typeset -g POWERLEVEL9K_ASDF_FLUTTER_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_ASDF_FLUTTER_BACKGROUND=$C_SUCCESS_ALT

typeset -g POWERLEVEL9K_ASDF_LUA_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_LUA_BACKGROUND=$C_INDIGO

typeset -g POWERLEVEL9K_ASDF_JAVA_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_JAVA_BACKGROUND=$C_NEON_PURPLE

typeset -g POWERLEVEL9K_ASDF_PERL_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_PERL_BACKGROUND=$C_INDIGO

typeset -g POWERLEVEL9K_ASDF_ERLANG_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_ERLANG_BACKGROUND=$C_ERROR

typeset -g POWERLEVEL9K_ASDF_ELIXIR_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_ELIXIR_BACKGROUND=$C_NEON_PURPLE

typeset -g POWERLEVEL9K_ASDF_POSTGRES_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_ASDF_POSTGRES_BACKGROUND=$C_SUCCESS_ALT

typeset -g POWERLEVEL9K_ASDF_PHP_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_PHP_BACKGROUND=$C_NEON_PURPLE

typeset -g POWERLEVEL9K_ASDF_HASKELL_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ASDF_HASKELL_BACKGROUND=$C_NEON_PURPLE

typeset -g POWERLEVEL9K_ASDF_JULIA_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_ASDF_JULIA_BACKGROUND=$C_SUCCESS

# ============================================================
# Python 系 - インディゴ背景
# ============================================================
# virtualenv: Python 仮想環境
typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=$C_INDIGO
# Python バージョンは非表示
typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
# pyenv と重複時は非表示
typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV=false
typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

# anaconda: conda 環境
typeset -g POWERLEVEL9K_ANACONDA_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_ANACONDA_BACKGROUND=$C_INDIGO
typeset -g POWERLEVEL9K_ANACONDA_CONTENT_EXPANSION='${${${${CONDA_PROMPT_MODIFIER#\(}% }%\)}:-${CONDA_PREFIX:t}}'

# pyenv
typeset -g POWERLEVEL9K_PYENV_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_PYENV_BACKGROUND=$C_INDIGO
typeset -g POWERLEVEL9K_PYENV_SOURCES=(shell local global)
typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false
typeset -g POWERLEVEL9K_PYENV_SHOW_SYSTEM=true
typeset -g POWERLEVEL9K_PYENV_CONTENT_EXPANSION='${P9K_CONTENT}${${P9K_CONTENT:#$P9K_PYENV_PYTHON_VERSION(|/*)}:+ $P9K_PYENV_PYTHON_VERSION}'

# ============================================================
# Node.js 系 - シアン背景
# ============================================================
# nodenv
typeset -g POWERLEVEL9K_NODENV_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_NODENV_BACKGROUND=$C_SUCCESS
typeset -g POWERLEVEL9K_NODENV_SOURCES=(shell local global)
typeset -g POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW=false
typeset -g POWERLEVEL9K_NODENV_SHOW_SYSTEM=true

# nvm
typeset -g POWERLEVEL9K_NVM_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_NVM_BACKGROUND=$C_SUCCESS
typeset -g POWERLEVEL9K_NVM_PROMPT_ALWAYS_SHOW=false
typeset -g POWERLEVEL9K_NVM_SHOW_SYSTEM=true

# nodeenv
typeset -g POWERLEVEL9K_NODEENV_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_NODEENV_BACKGROUND=$C_SUCCESS
typeset -g POWERLEVEL9K_NODEENV_SHOW_NODE_VERSION=false
typeset -g POWERLEVEL9K_NODEENV_{LEFT,RIGHT}_DELIMITER=

# node_version
typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_NODE_VERSION_BACKGROUND=$C_SUCCESS
typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true

# package.json
typeset -g POWERLEVEL9K_PACKAGE_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_PACKAGE_BACKGROUND=$C_SUCCESS_ALT

# ============================================================
# Go 系 - アクア背景
# ============================================================
# goenv
typeset -g POWERLEVEL9K_GOENV_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_GOENV_BACKGROUND=$C_SUCCESS_ALT
typeset -g POWERLEVEL9K_GOENV_SOURCES=(shell local global)
typeset -g POWERLEVEL9K_GOENV_PROMPT_ALWAYS_SHOW=false
typeset -g POWERLEVEL9K_GOENV_SHOW_SYSTEM=true

# go_version
typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_GO_VERSION_BACKGROUND=$C_SUCCESS_ALT
typeset -g POWERLEVEL9K_GO_VERSION_PROJECT_ONLY=true

# ============================================================
# Rust 系 - ネオンパープル背景
# ============================================================
# rust_version
typeset -g POWERLEVEL9K_RUST_VERSION_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_RUST_VERSION_BACKGROUND=$C_NEON_PURPLE
typeset -g POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY=true

# ============================================================
# Ruby 系 - ホットピンク背景
# ============================================================
# rbenv
typeset -g POWERLEVEL9K_RBENV_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_RBENV_BACKGROUND=$C_ERROR
typeset -g POWERLEVEL9K_RBENV_SOURCES=(shell local global)
typeset -g POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW=false
typeset -g POWERLEVEL9K_RBENV_SHOW_SYSTEM=true

# rvm
typeset -g POWERLEVEL9K_RVM_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_RVM_BACKGROUND=$C_ERROR
typeset -g POWERLEVEL9K_RVM_SHOW_GEMSET=false
typeset -g POWERLEVEL9K_RVM_SHOW_PREFIX=false

# ============================================================
# Java 系 - ネオンパープル背景
# ============================================================
# java_version
typeset -g POWERLEVEL9K_JAVA_VERSION_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_JAVA_VERSION_BACKGROUND=$C_NEON_PURPLE
typeset -g POWERLEVEL9K_JAVA_VERSION_PROJECT_ONLY=true
typeset -g POWERLEVEL9K_JAVA_VERSION_FULL=false

# jenv
typeset -g POWERLEVEL9K_JENV_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_JENV_BACKGROUND=$C_NEON_PURPLE
typeset -g POWERLEVEL9K_JENV_SOURCES=(shell local global)
typeset -g POWERLEVEL9K_JENV_PROMPT_ALWAYS_SHOW=false
typeset -g POWERLEVEL9K_JENV_SHOW_SYSTEM=true

# ============================================================
# PHP 系 - ネオンパープル背景
# ============================================================
# php_version
typeset -g POWERLEVEL9K_PHP_VERSION_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_PHP_VERSION_BACKGROUND=$C_NEON_PURPLE
typeset -g POWERLEVEL9K_PHP_VERSION_PROJECT_ONLY=true

# phpenv
typeset -g POWERLEVEL9K_PHPENV_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_PHPENV_BACKGROUND=$C_NEON_PURPLE
typeset -g POWERLEVEL9K_PHPENV_SOURCES=(shell local global)
typeset -g POWERLEVEL9K_PHPENV_PROMPT_ALWAYS_SHOW=false
typeset -g POWERLEVEL9K_PHPENV_SHOW_SYSTEM=true

# laravel
typeset -g POWERLEVEL9K_LARAVEL_VERSION_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_LARAVEL_VERSION_BACKGROUND=$C_ERROR

# ============================================================
# .NET 系 - ネオンパープル背景
# ============================================================
# dotnet_version
typeset -g POWERLEVEL9K_DOTNET_VERSION_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_DOTNET_VERSION_BACKGROUND=$C_NEON_PURPLE
typeset -g POWERLEVEL9K_DOTNET_VERSION_PROJECT_ONLY=true

# ============================================================
# Perl 系 - インディゴ背景
# ============================================================
# plenv
typeset -g POWERLEVEL9K_PLENV_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_PLENV_BACKGROUND=$C_INDIGO
typeset -g POWERLEVEL9K_PLENV_SOURCES=(shell local global)
typeset -g POWERLEVEL9K_PLENV_PROMPT_ALWAYS_SHOW=false
typeset -g POWERLEVEL9K_PLENV_SHOW_SYSTEM=true

# perlbrew
typeset -g POWERLEVEL9K_PERLBREW_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_PERLBREW_BACKGROUND=$C_INDIGO
typeset -g POWERLEVEL9K_PERLBREW_PROJECT_ONLY=true
typeset -g POWERLEVEL9K_PERLBREW_SHOW_PREFIX=false

# ============================================================
# Lua 系 - インディゴ背景
# ============================================================
# luaenv
typeset -g POWERLEVEL9K_LUAENV_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_LUAENV_BACKGROUND=$C_INDIGO
typeset -g POWERLEVEL9K_LUAENV_SOURCES=(shell local global)
typeset -g POWERLEVEL9K_LUAENV_PROMPT_ALWAYS_SHOW=false
typeset -g POWERLEVEL9K_LUAENV_SHOW_SYSTEM=true

# ============================================================
# Scala 系 - ホットピンク背景
# ============================================================
# scalaenv
typeset -g POWERLEVEL9K_SCALAENV_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_SCALAENV_BACKGROUND=$C_ERROR
typeset -g POWERLEVEL9K_SCALAENV_SOURCES=(shell local global)
typeset -g POWERLEVEL9K_SCALAENV_PROMPT_ALWAYS_SHOW=false
typeset -g POWERLEVEL9K_SCALAENV_SHOW_SYSTEM=true

# ============================================================
# Haskell 系 - ネオンパープル背景
# ============================================================
# haskell_stack
typeset -g POWERLEVEL9K_HASKELL_STACK_FOREGROUND=$C_WHITE
typeset -g POWERLEVEL9K_HASKELL_STACK_BACKGROUND=$C_NEON_PURPLE
typeset -g POWERLEVEL9K_HASKELL_STACK_SOURCES=(shell local)
typeset -g POWERLEVEL9K_HASKELL_STACK_ALWAYS_SHOW=true

# ============================================================
# Flutter/Dart 系 - アクア背景
# ============================================================
# fvm
typeset -g POWERLEVEL9K_FVM_FOREGROUND=$C_BLACK
typeset -g POWERLEVEL9K_FVM_BACKGROUND=$C_SUCCESS_ALT
