document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('appointment-form');
  const list = document.getElementById('appointment-list');
  const filterInput = document.getElementById('filter-input');
  const locationUpload = document.getElementById('location-upload');
  const generateBtn = document.getElementById('generate-weekly');

  let userCoords = null;

  navigator.geolocation.getCurrentPosition(position => {
    userCoords = {
      lat: position.coords.latitude,
      lng: position.coords.longitude
    };
    renderAppointments();
  }, () => {
    renderAppointments(); // fallback
  });

  function saveAppointments(appointments) {
    localStorage.setItem('appointments', JSON.stringify(appointments));
  }

  function loadAppointments() {
    return JSON.parse(localStorage.getItem('appointments')) || [];
  }

  function getDistance(loc1, loc2) {
    const toRad = deg => deg * Math.PI / 180;
    const R = 6371;
    const dLat = toRad(loc2.lat - loc1.lat);
    const dLng = toRad(loc2.lng - loc1.lng);
    const a = Math.sin(dLat / 2) ** 2 +
              Math.cos(toRad(loc1.lat)) * Math.cos(toRad(loc2.lat)) *
              Math.sin(dLng / 2) ** 2;
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  function geocodeAddress(address, callback) {
    const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(address)}`;
    fetch(url)
      .then(res => res.json())
      .then(data => {
        if (data.length > 0) {
          callback({ lat: parseFloat(data[0].lat), lng: parseFloat(data[0].lon) });
        } else {
          callback(null);
        }
      });
  }

  function renderAppointments() {
    list.innerHTML = '';
    let appointments = loadAppointments();

    const filterText = filterInput.value.toLowerCase();
    if (filterText) {
      appointments = appointments.filter(appt =>
        appt.title.toLowerCase().includes(filterText) ||
        appt.location.toLowerCase().includes(filterText)
      );
    }

    if (userCoords) {
      const promises = appointments.map(appt =>
        new Promise(resolve => {
          geocodeAddress(appt.location, coords => {
            appt._distance = coords ? getDistance(userCoords, coords) : Infinity;
            resolve(appt);
          });
        })
      );

      Promise.all(promises).then(sorted => {
        sorted.sort((a, b) => a._distance - b._distance);
        renderList(sorted);
      });
    } else {
      appointments.sort((a, b) => a.location.localeCompare(b.location));
      renderList(appointments);
    }
  }

  function renderList(appointments) {
    list.innerHTML = '';
    appointments.forEach((appt, index) => {
      const li = document.createElement('li');
      li.textContent = `${appt.title} - ${appt.datetime} @ ${appt.location}`;
      const del = document.createElement('button');
      del.textContent = 'Delete';
      del.onclick = () => {
        let all = loadAppointments();
        all.splice(index, 1);
        saveAppointments(all);
        renderAppointments();
      };
      const mapBtn = document.createElement('button');
      mapBtn.textContent = 'Map';
      mapBtn.onclick = () => {
        window.open(`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(appt.location)}`);
      };
      li.appendChild(del);
      li.appendChild(mapBtn);
      list.appendChild(li);
    });
  }

  form.addEventListener('submit', e => {
    e.preventDefault();
    const title = document.getElementById('title').value;
    const datetime = document.getElementById('datetime').value;
    const location = document.getElementById('location').value;

    const appointments = loadAppointments();
    appointments.push({ title, datetime, location });
    saveAppointments(appointments);
    renderAppointments();
    form.reset();
  });

  filterInput.addEventListener('input', renderAppointments);

  generateBtn.addEventListener('click', () => {
    const lines = locationUpload.value.split('\n').map(l => l.trim()).filter(l => l);
    if (lines.length === 0) return alert('Please enter at least one location.');

    const today = new Date();
    const appointments = loadAppointments();

    for (let i = 0; i < Math.min(7, lines.length); i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      date.setHours(10, 0, 0, 0); // 10 AM
      const iso = date.toISOString().slice(0, 16); // yyyy-MM-ddTHH:mm

      appointments.push({
        title: `Visit: ${lines[i]}`,
        datetime: iso,
        location: lines[i]
      });
    }

    saveAppointments(appointments);
    renderAppointments();
    locationUpload.value = '';
  });
});
