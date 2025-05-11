<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\URL;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if (app()->environment('production')) {
            URL::forceScheme('https');
            
            // Handle missing Vite manifest in production
            if (!file_exists(public_path('build/manifest.json'))) {
                // Create directory if it doesn't exist
                if (!is_dir(public_path('build'))) {
                    mkdir(public_path('build'), 0755, true);
                }
                
                // Create an empty manifest file
                file_put_contents(
                    public_path('build/manifest.json'),
                    json_encode([])
                );
            }
        }
    }
}
