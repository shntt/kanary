// スクロール処理
function smoothScroll(target) {
    const targetElement = typeof target === 'string' ? document.querySelector(target) : target;
    
    if (!targetElement) return;

    const headerHeight = 80;
    const targetPosition = targetElement.getBoundingClientRect().top + window.pageYOffset - headerHeight;

    window.scrollTo({
        top: targetPosition,
        behavior: 'smooth'
    });
}

// イベントリスナーの設定
function initSmoothScroll() {
    // スクロールリンクの処理
    const scrollLinks = document.querySelectorAll('.scroll-link');
    scrollLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            smoothScroll(targetId);
        });
    });

    // ロゴクリックでトップへスクロール
    const logo = document.getElementById('logo');
    if (logo) {
        logo.addEventListener('click', function() {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
}

function switchTab(tabName) {
    // コンテンツの切り替え
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.add('hidden');
    });
    document.getElementById(tabName).classList.remove('hidden');

    // タブボタンのスタイル切り替え
    document.querySelectorAll('.tab-button').forEach(button => {
        button.classList.remove('bg-black', 'text-white');
        button.classList.add('text-gray-600', 'hover:text-gray-900');
    });
    document.querySelector(`[data-tab="${tabName}"]`).classList.remove('text-gray-600', 'hover:text-gray-900');
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('bg-black', 'text-white');
}

function initializeTabs() {
    const tabButtons = document.querySelectorAll('.tab-button');
    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const tabName = button.getAttribute('data-tab');
            switchTab(tabName);
        });
    });
}

function toggleMenu() {
    const mobileMenu = document.querySelector('.mobile-menu');
    const menuIcon = document.querySelector('.menu-icon');
    const closeIcon = document.querySelector('.close-icon');
    
    mobileMenu.classList.toggle('hidden');
    menuIcon.classList.toggle('hidden');
    closeIcon.classList.toggle('hidden');
  }

  // ハンバーガーメニューの制御
function initMobileMenu() {
    const menuButton = document.querySelector('button[aria-label="メニュー"]');
    if (menuButton) {
      menuButton.addEventListener('click', toggleMenu);
    }
  
    // モバイルメニュー内のリンクをクリックしたときにメニューを閉じる
    const mobileMenuLinks = document.querySelectorAll('.mobile-menu a');
    mobileMenuLinks.forEach(link => {
      link.addEventListener('click', () => {
        const mobileMenu = document.querySelector('.mobile-menu');
        const menuIcon = document.querySelector('.menu-icon');
        const closeIcon = document.querySelector('.close-icon');
        
        mobileMenu.classList.add('hidden');
        menuIcon.classList.remove('hidden');
        closeIcon.classList.add('hidden');
      });
    });
  }
  
// タブの制御
document.addEventListener('DOMContentLoaded', function() {
    // タブボタンとコンテンツを取得
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabContents = document.querySelectorAll('.tab-content');

    // 初期状態の設定（インストールタブを表示）
    tabContents.forEach(content => {
        content.style.display = 'none';
    });
    document.getElementById('install-content').style.display = 'block';
    tabButtons[0].classList.add('bg-black', 'text-white');
    tabButtons[1].classList.remove('bg-black', 'text-white');

    // タブクリックイベントの設定
    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            // すべてのコンテンツを非表示
            tabContents.forEach(content => {
                content.style.display = 'none';
            });

            // すべてのボタンのスタイルをリセット
            tabButtons.forEach(btn => {
                btn.classList.remove('bg-black', 'text-white');
                btn.classList.add('text-gray-600');
            });

            // クリックされたタブに対応するコンテンツを表示
            const tabId = button.getAttribute('data-tab');
            document.getElementById(tabId).style.display = 'block';

            // クリックされたボタンのスタイルを変更
            button.classList.add('bg-black', 'text-white');
            button.classList.remove('text-gray-600');
        });
    });
});

// DOMの読み込み完了時に全ての初期化を実行
document.addEventListener('DOMContentLoaded', () => {
    initSmoothScroll();
    initializeTabs();
    initMobileMenu();
});

export { smoothScroll, initSmoothScroll, switchTab };