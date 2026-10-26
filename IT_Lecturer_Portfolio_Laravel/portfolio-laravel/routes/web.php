<?php

use App\Http\Controllers\AccountController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\PortfolioController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\SectionController;
use App\Http\Controllers\UserController;
use App\Http\Middleware\AdminOnly;
use App\Support\Sections;
use Illuminate\Support\Facades\Route;

Route::get('/', [PortfolioController::class, 'home'])->name('home');

// ---- Authentication ----
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:6,1');
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:6,1');
});
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth')->name('logout');

// ---- Back office (every logged-in user manages their own portfolio) ----
Route::middleware('auth')->prefix('admin')->name('admin.')->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    Route::post('/manage/stop', [DashboardController::class, 'stopManaging'])->name('manage.stop');

    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::put('/profile', [ProfileController::class, 'update'])->name('profile.update');

    Route::get('/account', [AccountController::class, 'edit'])->name('account.edit');
    Route::put('/account', [AccountController::class, 'update'])->name('account.update');

    // Generic CRUD for: stats, highlights, experiences, skills, projects, topics
    Route::prefix('s/{section}')->name('section.')->where(['section' => Sections::pattern()])->group(function () {
        Route::get('/', [SectionController::class, 'index'])->name('index');
        Route::get('/create', [SectionController::class, 'create'])->name('create');
        Route::post('/', [SectionController::class, 'store'])->name('store');
        Route::get('/{id}/edit', [SectionController::class, 'edit'])->whereNumber('id')->name('edit');
        Route::put('/{id}', [SectionController::class, 'update'])->whereNumber('id')->name('update');
        Route::delete('/{id}', [SectionController::class, 'destroy'])->whereNumber('id')->name('destroy');
    });

    // Admin only: user management + "manage as"
    Route::middleware(AdminOnly::class)->group(function () {
        Route::resource('users', UserController::class)->except('show');
        Route::post('users/{user}/manage', [UserController::class, 'manage'])->name('users.manage');
    });
});

// ---- Public portfolio: /{username}  (keep this LAST) ----
Route::get('/{username}', [PortfolioController::class, 'show'])
    ->where('username', '[A-Za-z0-9_-]+')
    ->name('portfolio.show');
