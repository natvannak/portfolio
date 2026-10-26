<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Support\Rules;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    public function showLogin()
    {
        return view('auth.login');
    }

    public function login(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $attempt = [
            'email' => $credentials['email'],
            'password' => $credentials['password'],
            'is_active' => true,
        ];

        if (Auth::attempt($attempt, $request->boolean('remember'))) {
            $request->session()->regenerate();

            return redirect()->intended(route('admin.dashboard'));
        }

        return back()->withErrors(['email' => 'Invalid credentials, or the account is disabled.'])->onlyInput('email');
    }

    public function showRegister()
    {
        abort_unless(config('portfolio.allow_registration'), 404);

        return view('auth.register');
    }

    public function register(Request $request): RedirectResponse
    {
        abort_unless(config('portfolio.allow_registration'), 404);

        $request->merge(['username' => strtolower((string) $request->input('username'))]);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'username' => Rules::username(),
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'confirmed', Password::min(8)],
        ]);

        $user = new User($data);
        $user->role = 'user';
        $user->is_active = true;
        $user->save();

        Auth::login($user);
        $request->session()->regenerate();

        return redirect()->route('admin.profile.edit')->with('status', 'Welcome! Fill in your profile, then publish your portfolio.');
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('home');
    }
}
