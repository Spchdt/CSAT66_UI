# CSAT66_UI

**CSAT66_UI** is a versatile window application developed using Flutter, designed to display and interact with data from the CSAT66 satellite. The program connects to a Python script via WebSocket, enabling real-time data monitoring and visualization. 

**Key Features:**

- **Status Monitoring:** Displays critical satellite data, including gyrometers, accelerometers, temperature, heading, latitude, longitude, and altitude.
- **Image and Video Display:** Supports displaying images from RX-STTV and the device's video input for enhanced situational awareness.
- **Mapping & Visualization:** Marks the satellite's location on a map and includes a 3D model visualization that dynamically updates based on heading data.
- **Graphical Data Representation:** Provides real-time temperature and altitude graphs for quick analysis.
- **Customization:** Allows the WebSocket port to be easily changed via a configuration file in the assets folder.
