package com.example.TankWar.Model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="projectile")
public class Projectile {
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private int id;
	
	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}


	private double angle;           
    private double power;           
    private int damage;             
    private String type;            
    private double positionX;       
    private double positionY;       
    private boolean isActive;       

    
    public Projectile() {}

    public Projectile(double angle, double power, String type) {
        this.angle = angle;
        this.power = power;
        this.type = type;
        this.damage = calculateDamage(type);  
        this.positionX = 0.0;   
        this.positionY = 0.0;
        this.isActive = true;
    }
    

    // Getters and Setters
    public double getAngle() {
        return angle;
    }

    public void setAngle(double angle) {
        this.angle = angle;
    }

    public double getPower() {
        return power;
    }

    public void setPower(double power) {
        this.power = power;
    }

    public int getDamage() {
        return damage;
    }

    public void setDamage(int damage) {
        this.damage = damage;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public double getPositionX() {
        return positionX;
    }

    public void setPositionX(double positionX) {
        this.positionX = positionX;
    }

    public double getPositionY() {
        return positionY;
    }

    public void setPositionY(double positionY) {
        this.positionY = positionY;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

   
    private int calculateDamage(String type) {
        switch (type) {
            case "missile":
                return 50;
            case "cannonball":
                return 30;
            default:
                return 20;  
        }
    }

   
    public void move() {
        
        double radians = Math.toRadians(angle);
        this.positionX += power * Math.cos(radians);
        this.positionY += power * Math.sin(radians) - 9.8; 
        
        if (this.positionY < 0) {
            this.positionY = 0;
            this.isActive = false;
        }
    }
}
