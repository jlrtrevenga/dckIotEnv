# Iot Front-Back prototipe, docker


- Iot devices 
    - remote ESP32 Heater Controller (not in this project)


- Cloud Backend (docker based)
    
    Gateway: 
        - eclipse-mosquitto +
        - mqtt gateway (python, eclipse paho)

        (Alternative: - Fiware: Orion + Mongo + MQTT IoT Agent)
    
    Persistence: 
        - postgresql DD.BB.
        - pgadmin
        - cloudbeaver 

    Workflows scheduler and monitoring: 
        - Airflow


- FrontEnd 01:
    - angular/flask (TODO)
    - grafana 

- FrontEnd 02:
    - Android + flutter 




#![Alt text](relative/path/to/img.jpg?raw=true "Title")
#![plot](./directory_1/directory_2/.../directory_n/plot.png)




## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them


### Installing

A step by step series of examples that tell you how to get a development env running

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system


## Authors

JLRT - Jose Luis Rodriguez de Torres


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


## Acknowledgments

This project has been inspired by Victor Seifert articles. 
Although there are differences between both projects, carefull reading of his articles is recommended:


https://towardsdatascience.com/how-to-build-a-data-lake-from-scratch-part-1-the-setup-34ea1665a06e

https://towardsdatascience.com/how-to-build-a-data-lake-from-scratch-part-2-connecting-the-components-1bc659cb3f4f

