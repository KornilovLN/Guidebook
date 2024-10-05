
1. Установите Neovim:
```
sudo apt install neovim
```

2. Установите менеджер плагинов vim-plug:
```
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

3. Создайте конфигурационный файл:
```
mkdir -p ~/.config/nvim
touch ~/.config/nvim/init.vim
```

4. Добавьте следующее содержимое в init.vim:
```
call plug#begin()
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
Plug 'rust-lang/rust.vim'
Plug 'fatih/vim-go'
Plug 'vim-python/python-syntax'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()

lua << EOF
require'lspconfig'.clangd.setup{}
require'lspconfig'.pyright.setup{}
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.gopls.setup{}
EOF
```

5. Установите плагины:
<br>Откройте Neovim и выполните команду
```
:PlugInstall
```

6. Установите языковые серверы:
```
sudo apt install clangd
pip install pyright
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
go install golang.org/x/tools/gopls@latest
```
