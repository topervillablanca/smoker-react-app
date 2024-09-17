# Documentation: Cigarette Smoking Problem Project

## 1. Overview

The Cigarette Smoking Problem is a classic synchronization problem where an agent and smokers need to coordinate in a way that allows smokers to smoke cigarettes. Each smoker needs three ingredients (tobacco, paper, and matches) to smoke, but the agent provides only two of these ingredients at a time. The challenge is to ensure that each smoker receives the needed ingredient while the agent randomly selects which ingredients to provide.

## 2. Project Description

This project simulates the Cigarette Smoking Problem using OCaml. It involves:

- An agent that randomly provides two different ingredients.
- Three smokers, each needing a specific ingredient to smoke.
- An HTTP server that exposes the current available ingredients.

## 3. Components

1. **OCaml Backend**:
   - Manages the simulation and provides an HTTP API.
   - Uses Lwt for concurrency and Cohttp for HTTP handling.

2. **React Frontend**:
   - Fetches data from the OCaml backend using Axios.
   - Displays the available ingredients.

## 4. Setting Up the OCaml Backend

### 4.1. Install Dependencies

```sh
opam install lwt cohttp-lwt-unix
