package com.example.TankWar.Model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
@Entity
@Table(name="terrains")
public class Terrain {
	public boolean isHasObstacles() {
		return hasObstacles;
	}

		public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}


		@Id
		@GeneratedValue(strategy=GenerationType.IDENTITY)
		private int id;
		
	 	private String type;             
	    private double friction;         
	    private double gravityModifier;   
	    private boolean hasObstacles;     

	    
	    public Terrain() {}

	    public Terrain(String type, double friction, double gravityModifier, boolean hasObstacles) {
	        this.type = type;
	        this.friction = friction;
	        this.gravityModifier = gravityModifier;
	        this.hasObstacles = hasObstacles;
	    }

	    
	    public String getType() {
	        return type;
	    }

	    public void setType(String type) {
	        this.type = type;
	    }

	    public double getFriction() {
	        return friction;
	    }

	    public void setFriction(double friction) {
	        this.friction = friction;
	    }

	    public double getGravityModifier() {
	        return gravityModifier;
	    }

	    public void setGravityModifier(double gravityModifier) {
	        this.gravityModifier = gravityModifier;
	    }

	    public boolean hasObstacles() {
	        return hasObstacles;
	    }

	    public void setHasObstacles(boolean hasObstacles) {
	        this.hasObstacles = hasObstacles;
	    }

	   
	    public double adjustPowerForTerrain(double power) {
	        return power * (1 - friction);
	    }

	    
	    public double adjustGravity(double baseGravity) {
	        return baseGravity * gravityModifier;
	    }

}
