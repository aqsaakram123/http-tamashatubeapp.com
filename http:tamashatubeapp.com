<!DOCTYPE html>
<html>
<head>
    <title>Tamsaha Tube</title>
    <style>
        .search-bar { display: flex; align-items: center; padding: 10px; }
        .search-input { flex-grow: 1; padding: 8px; border: 1px solid #ccc; }
        .mic-button { padding: 8px; margin-left: 5px; cursor: pointer; }
        .video-list, .shorts-list { display: flex; flex-wrap: wrap; gap: 15px; padding: 10px; }
        .video-item, .short-item { width: 300px; border: 1px solid #eee; padding: 10px; }
        .sidebar { width: 200px; position: fixed; top: 60px; left: 0; padding: 10px; }
        .sidebar ul { list-style: none; padding: 0; }
        .sidebar li a { display: block; padding: 8px 0; text-decoration: none; }
    </style>
</head>
<body>
    <div class="search-bar">
        <input type="text" class="search-input" placeholder="Search...">
        <button class="mic-button">🎤</button>
        <button>Search</button>
    </div>

    <h2>Videos</h2>
    <div class="video-list">
        {% for video in videos %}
            <div class="video-item">
                <a href="{% url 'play_video' video.id %}">
                    <img src="{{ video.thumbnail_url|default:'https://via.placeholder.com/300x200' }}" alt="Thumbnail" width="300">
                    <h3>{{ video.title }}</h3>
                </a>
                <p>{{ video.description|truncatechars:100 }}</p>
            </div>
        {% empty %}
            <p>No videos available.</p>
        {% endfor %}
    </div>

    <h2>Shorts</h2>
    <div class="shorts-list">
        {% for short in shorts %}
            <div class="short-item">
                <video controls width="150" height="200">
                    <source src="{{ short.video_url }}" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
                <p>{{ short.title }}</p>
            </div>
        {% empty %}
            <p>No shorts available.</p>
        {% endfor %}
    </div>

    <div class="sidebar">
        <h3>Menu</h3>
        <ul>
            <li><a href="/">Home</a></li>
            <li><a href="{% url 'shorts_page' %}">Shorts</a></li>
            <li><a href="/subscriptions/">Subscriptions</a></li>
            <li><a href="/music/">Music</a></li>
            <li><a href="/sports/">Sports</a></li>
            <li><a href="/games/">Games</a></li>
            {% if user.is_authenticated %}
                <li><a href="{% url 'signout' %}">Sign Out</a></li>
            {% else %}
                <li><a href="{% url 'signin' %}">Sign In</a></li>
                <li><a href="{% url 'signup' %}">Sign Up</a></li>
            {% endif %}
        </ul>
    </div>

    <script>
        const micButton = document.querySelector('.mic-button');
        const searchInput = document.querySelector('.search-input');
        const recognition = new (window.SpeechRecognition || window.webkitSpeechRecognition)();

        recognition.lang = 'en-US';
        recognition.interimResults = false;
        recognition.maxAlternatives = 1;

        micButton.addEventListener('click', () => {
            recognition.start();
        });

        recognition.onresult = (event) => {
            const speechResult = event.results[0][0].transcript;
            searchInput.value = speechResult;
            // Yahan aap search form submit ya AJAX request bhej sakte hain
            console.log('Spoken: ' + speechResult);
        };

        recognition.onspeechend = () => {
            recognition.stop();
        };

        recognition.onerror = (event) => {
            cons
ole.error('Speech recognition error: ' + event.error);
        };
    </script>
</body>
</html>




