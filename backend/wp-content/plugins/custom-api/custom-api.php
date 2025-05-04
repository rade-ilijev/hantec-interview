<?php
/**
 * Plugin Name: Custom API
 * Description: REST API for Vue frontend.
 * Version: 1.0
 * Author: Your Name
 * License: GPL2
 */

// Ensure direct access is not allowed
if (!defined('ABSPATH')) {
    exit;
}

// Add REST API support
add_action('init', function() {
    add_filter('rest_authentication_errors', function($result) {
        error_log('=== REST API Authentication Filter ===');
        error_log('Request URI: ' . $_SERVER['REQUEST_URI']);
        error_log('Request method: ' . $_SERVER['REQUEST_METHOD']);
        error_log('Request headers: ' . print_r(getallheaders(), true));
        
        if (!empty($result)) {
            error_log('Existing result: ' . print_r($result, true));
            return $result;
        }
        
        // Allow public access to our custom endpoints
        if (strpos($_SERVER['REQUEST_URI'], '/wp-json/custom/v1/posts') !== false ||
            strpos($_SERVER['REQUEST_URI'], '/wp-json/custom/v1/post/') !== false ||
            strpos($_SERVER['REQUEST_URI'], '/wp-json/custom/v1/is-authenticated') !== false ||
            strpos($_SERVER['REQUEST_URI'], '/wp-json/custom/v1/logout') !== false) {
            error_log('Allowing public access to: ' . $_SERVER['REQUEST_URI']);
            return true;
        }
        
        if (!is_user_logged_in()) {
            error_log('User not logged in, allowing access');
            return true;
        }
        
        error_log('Default authentication check');
        return $result;
    });
});

// Initialize REST API routes
add_action('rest_api_init', function () {
    // Login route
    register_rest_route('custom/v1', '/login', [
        'methods' => 'POST',
        'callback' => 'custom_api_login',
        'permission_callback' => '__return_true'
    ]);

    // Logout route
    register_rest_route('custom/v1', '/logout', [
        'methods' => 'POST',
        'callback' => 'custom_api_logout',
        'permission_callback' => '__return_true'
    ]);

    register_rest_route('custom/v1', '/is-authenticated', [
        'methods' => 'GET',
        'callback' => 'is_rest_user_authenticated',
        'permission_callback' => '__return_true',
    ]);

    // Get posts route
    register_rest_route('custom/v1', '/posts', [
        'methods' => 'GET',
        'callback' => 'custom_api_get_posts',
        'permission_callback' => 'custom_api_check_auth'
    ]);

    // Get single post route
    register_rest_route('custom/v1', '/post/(?P<id>\d+)', [
        'methods' => 'GET',
        'callback' => 'custom_api_get_post',
        'permission_callback' => 'custom_api_check_auth'
    ]);

    // Delete post route
    register_rest_route('custom/v1', '/post/(?P<id>\d+)', [
        'methods' => 'DELETE',
        'callback' => 'custom_api_delete_post',
        'permission_callback' => 'custom_api_check_auth'
    ]);
});

// Handle login
function custom_api_login($request) {
    try {
        error_log('=== Login Process Start ===');
        
        $creds = [
            'user_login' => sanitize_text_field($request['username']),
            'user_password' => $request['password'],
            'remember' => true
        ];

        $user = wp_signon($creds, false);
        if (is_wp_error($user)) {
            error_log('Login failed: ' . $user->get_error_message());
            return new WP_Error('unauthorized', 'Invalid credentials', ['status' => 403]);
        }

        // Set the current user
        wp_set_current_user($user->ID);
        wp_set_auth_cookie($user->ID, true);

        // Create a new nonce
        $nonce = wp_create_nonce('wp_rest');

        error_log('Login successful for user: ' . $user->user_login);
        error_log('User ID: ' . $user->ID);
        error_log('Generated nonce: ' . $nonce);

        return [
            'message' => 'Login successful',
            'token' => $nonce,
            'user' => [
                'id' => $user->ID,
                'name' => $user->display_name,
                'email' => $user->user_email,
                'roles' => $user->roles
            ]
        ];
    } catch (Exception $e) {
        error_log('Login error: ' . $e->getMessage());
        return new WP_Error('login_failed', 'Login failed: ' . $e->getMessage(), ['status' => 500]);
    }
}

function is_rest_user_authenticated($request) {
    try {
        error_log('=== Authentication Check Start ===');
        
        if (is_user_logged_in()) {
            $user = wp_get_current_user();
            error_log('User is authenticated: ' . $user->user_login);
            
            return new WP_REST_Response([
                'authenticated' => true,
                'user_id' => $user->ID,
                'user_login' => $user->user_login,
                'user_email' => $user->user_email,
            ], 200);
        }
        
        error_log('User is not authenticated');
        return new WP_REST_Response([
            'authenticated' => false,
            'message' => 'User not authenticated',
        ], 401);
    } catch (Exception $e) {
        error_log('Auth check error: ' . $e->getMessage());
        return new WP_Error('auth_check_failed', 'Authentication check failed: ' . $e->getMessage(), ['status' => 500]);
    }
}

// Add logout function
function custom_api_logout($request) {
    try {
        error_log('=== Logout Process Start ===');
        error_log('Request headers: ' . print_r(getallheaders(), true));
        
        // Get the nonce from the request
        $nonce = $request->get_header('X-WP-Nonce');
        error_log('Received nonce: ' . $nonce);
        
        // Check if user is logged in first
        if (!is_user_logged_in()) {
            error_log('User is not logged in');
            return new WP_Error('not_logged_in', 'User is not logged in', ['status' => 401]);
        }
        
        // Get current user before logout
        $user = wp_get_current_user();
        error_log('Current user before logout: ' . $user->user_login);
        
        // Perform WordPress logout
        wp_logout();
        
        // Clear auth cookie
        wp_clear_auth_cookie();
        
        // Clear current user
        wp_set_current_user(0);
        
        error_log('=== Logout Process Complete ===');
        
        return new WP_REST_Response([
            'message' => 'Logged out successfully',
            'authenticated' => false
        ], 200);
        
    } catch (Exception $e) {
        error_log('Logout error: ' . $e->getMessage());
        error_log('Error trace: ' . $e->getTraceAsString());
        
        return new WP_Error(
            'logout_failed',
            'Failed to logout: ' . $e->getMessage(),
            ['status' => 500]
        );
    }
}


// Check user authentication
function custom_api_check_auth() {
    try {
        error_log('=== Auth Check Start ===');
        
        if (!is_user_logged_in()) {
            error_log('User is not logged in');
            return false;
        }
        
        $user = wp_get_current_user();
        error_log('User is logged in: ' . $user->user_login);
        return true;
    } catch (Exception $e) {
        error_log('Auth check error: ' . $e->getMessage());
        return false;
    }
}

// Get list of posts
function custom_api_get_posts() {
    try {
        error_log('=== Fetching Posts ===');
        
        $query = new WP_Query([
            'post_type' => 'post',
            'posts_per_page' => 10,
            'post_status' => 'publish'
        ]);

        $posts = [];
        while ($query->have_posts()) {
            $query->the_post();
            $posts[] = [
                'id' => get_the_ID(),
                'title' => get_the_title(),
                'excerpt' => get_the_excerpt(),
                'date' => get_the_date('', $post),
                'time' => get_the_time('', $post),
                'author' => get_the_author(),
                'thumbnail' => get_the_post_thumbnail_url(get_the_ID(), 'thumbnail'),
                'link' => get_permalink()
            ];
        }

        wp_reset_postdata();
        error_log('Successfully fetched ' . count($posts) . ' posts');
        return $posts;
    } catch (Exception $e) {
        error_log('Error fetching posts: ' . $e->getMessage());
        return new WP_Error('fetch_posts_failed', 'Failed to fetch posts: ' . $e->getMessage(), ['status' => 500]);
    }
}

// Get a single post
function custom_api_get_post($request) {
    try {
        error_log('=== Fetching Single Post ===');
        error_log('Post ID: ' . $request['id']);
        
        $post = get_post($request['id']);
        if (!$post) {
            error_log('Post not found');
            return new WP_Error('not_found', 'Post not found', ['status' => 404]);
        } elseif ($post->post_status !== 'publish' || $post->post_type !== 'post') {
            error_log('Post is not published or not a post type');
            return new WP_Error('not_found', 'Post not found', ['status' => 404]);
        }

        $post_data = [
            'id' => $post->ID,
            'title' => get_the_title($post),
            'content' => apply_filters('the_content', $post->post_content),
            'date' => get_the_date('', $post),
            'time' => get_the_time('', $post),
            'author' => get_the_author_meta('display_name', $post->post_author),
            'thumbnail' => get_the_post_thumbnail_url($post->ID, 'full'),
            'link' => get_permalink($post)
        ];
        
        error_log('Successfully fetched post: ' . $post->post_title);
        return $post_data;
    } catch (Exception $e) {
        error_log('Error fetching post: ' . $e->getMessage());
        return new WP_Error('fetch_post_failed', 'Failed to fetch post: ' . $e->getMessage(), ['status' => 500]);
    }
}

// Delete a post
function custom_api_delete_post($request) {
    try {
        error_log('=== Deleting Post ===');
        error_log('Post ID: ' . $request['id']);
        
        if (!current_user_can('delete_posts')) {
            error_log('User not authorized to delete posts');
            return new WP_Error('forbidden', 'Not allowed', ['status' => 403]);
        }

        $post_id = $request['id'];
        $deleted = wp_delete_post($post_id, true);
        
        if (!$deleted) {
            error_log('Failed to delete post');
            return new WP_Error('delete_failed', 'Delete failed', ['status' => 500]);
        }
        
        error_log('Successfully deleted post');
        return ['message' => 'Post deleted'];
    } catch (Exception $e) {
        error_log('Error deleting post: ' . $e->getMessage());
        return new WP_Error('delete_post_failed', 'Failed to delete post: ' . $e->getMessage(), ['status' => 500]);
    }
}

// Activation hook
register_activation_hook(__FILE__, 'custom_api_activate');
function custom_api_activate() {
    // Flush rewrite rules on activation
    flush_rewrite_rules();
}

// Deactivation hook
register_deactivation_hook(__FILE__, 'custom_api_deactivate');
function custom_api_deactivate() {
    // Flush rewrite rules on deactivation
    flush_rewrite_rules();
}
