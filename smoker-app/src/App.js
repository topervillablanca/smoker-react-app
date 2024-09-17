import React, { useEffect, useState } from 'react';
import axios from 'axios';

const IngredientsList = () => {
  const [ingredients, setIngredients] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Function to fetch ingredients from the OCaml backend
    const fetchIngredients = async () => {
      try {
        // Replace with your OCaml backend URL
        const response = await axios.get('http://localhost:8081/ingredients');
        setIngredients(response.data);
        setLoading(false);
      } catch (err) {
        setError(err);
        setLoading(false);
      }
    };

    fetchIngredients();
  }, []);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error.message}</p>;

  return (
    <div>
      <h1>Available Ingredients</h1>
      <p>{ingredients}</p>
    </div>
  );
};

export default IngredientsList;
